(** * Classification of the [×] Type *)
(** In this file, we classify the basic structure of [×] types ([prod]
    in Coq).  In particular, we classify equalities of non-dependent
    pairs (inhabitants of [×] types), so that when we have an equality
    between two such pairs, or when we want such an equality, we have
    a systematic way of reducing such equalities to equalities at
    simpler types. *)
Require Import Coq.Classes.Morphisms.
Require Import Coq.Setoids.Setoid.
Require Import Coq.Bool.Bool.
Require Import Rewriter.Util.IffT.
Require Import Rewriter.Util.Equality.
Require Import Rewriter.Util.GlobalSettings.

Local Arguments fst {_ _} _.
Local Arguments snd {_ _} _.
Local Arguments f_equal {_ _} _ {_ _} _.

Scheme Equality for prod.

Definition prod_beq_hetero {A1 B1 A2 B2} (A_beq_hetero : A1 -> A2 -> bool) (B_beq_hetero : B1 -> B2 -> bool)
           (x : A1 * B1) (y : A2 * B2) : bool
  := (A_beq_hetero (fst x) (fst y) && B_beq_hetero (snd x) (snd y))%bool.

Arguments prod_beq_hetero {_ _ _ _} _ _ x y / .

Lemma prod_bl_hetero {A1 B1 A2 B2}
      {A_beq_hetero : A1 -> A2 -> bool} {A_R : A1 -> A2 -> Prop}
      {B_beq_hetero : B1 -> B2 -> bool} {B_R : B1 -> B2 -> Prop}
      (A_bl : forall x y, A_beq_hetero x y = true -> A_R x y)
      (B_bl : forall x y, B_beq_hetero x y = true -> B_R x y)
      {x y}
  : prod_beq_hetero A_beq_hetero B_beq_hetero x y = true -> A_R (fst x) (fst y) /\ B_R (snd x) (snd y).
Proof using Type.
  destruct x, y; cbn in *; rewrite ?Bool.andb_true_iff; intuition auto.
Qed.

Lemma prod_lb_hetero {A1 B1 A2 B2}
      {A_beq_hetero : A1 -> A2 -> bool} {A_R : A1 -> A2 -> Prop}
      {B_beq_hetero : B1 -> B2 -> bool} {B_R : B1 -> B2 -> Prop}
      (A_lb : forall x y, A_R x y -> A_beq_hetero x y = true)
      (B_lb : forall x y, B_R x y -> B_beq_hetero x y = true)
      {x y}
  : A_R (fst x) (fst y) /\ B_R (snd x) (snd y) -> prod_beq_hetero A_beq_hetero B_beq_hetero x y = true.
Proof using Type.
  destruct x, y; cbn in *; rewrite ?Bool.andb_true_iff; intuition auto.
Qed.

Lemma prod_beq_hetero_uniform {A B : Type} A_beq B_beq {x y}
  : prod_beq_hetero A_beq B_beq x y = @prod_beq A B A_beq B_beq x y.
Proof. destruct x, y; reflexivity. Qed.

Lemma prod_bl_hetero_eq {A B}
      {A_beq : A -> A -> bool}
      {B_beq : B -> B -> bool}
      (A_bl : forall x y, A_beq x y = true -> x = y)
      (B_bl : forall x y, B_beq x y = true -> x = y)
      {x y}
  : prod_beq_hetero A_beq B_beq x y = true -> x = y.
Proof using Type. rewrite prod_beq_hetero_uniform; now apply internal_prod_dec_bl. Qed.

Lemma prod_lb_hetero_eq {A B}
      {A_beq : A -> A -> bool}
      {B_beq : B -> B -> bool}
      (A_lb : forall x y, x = y -> A_beq x y = true)
      (B_lb : forall x y, x = y -> B_beq x y = true)
      {x y}
  : x = y -> prod_beq_hetero A_beq B_beq x y = true.
Proof using Type. rewrite prod_beq_hetero_uniform; now apply internal_prod_dec_lb. Qed.

(* We would use [Scheme Minimality for prod Sort Type.], but we want
   [prod_rect_nodep] to unfold directly to [prod_rect] so that
   unification doesn't have a hard time unifying [prod_rect] and
   [prod_rect_nodep] on large arguments. *)
Definition prod_rect_nodep {A B P} : (A -> B -> P) -> A * B -> P
  := @prod_rect A B (fun _ => P).
(** Strongly prefer unfolding this version of [prod_rect] to the
    underlying [prod_rect] principle.  Possibly -1 would suffice rather
    than expand, but I don't think there's harm in [expand] because
    [prod_rect] ought not be much more complicated than any of these *)
Global Strategy expand [prod_rect_nodep].

Definition fst_pair {A B} (a:A) (b:B) : fst (a,b) = a := eq_refl.
Definition snd_pair {A B} (a:A) (b:B) : snd (a,b) = b := eq_refl.
Create HintDb cancel_pair discriminated. Hint Rewrite @fst_pair @snd_pair : cancel_pair.

(** ** Equality for [prod] *)
Section prod.
  (** *** Projecting an equality of a pair to equality of the first components *)
  Definition fst_path {A B} {u v : prod A B} (p : u = v)
  : fst u = fst v
    := f_equal fst p.

  (** *** Projecting an equality of a pair to equality of the second components *)
  Definition snd_path {A B} {u v : prod A B} (p : u = v)
  : snd u = snd v
    := f_equal snd p.

  (** *** Equality of [prod] is itself a [prod] *)
  Definition path_prod_uncurried {A B : Type} (u v : prod A B)
             (pq : prod (fst u = fst v) (snd u = snd v))
    : u = v.
  Proof.
    destruct u as [u1 u2], v as [v1 v2]; simpl in *.
    destruct pq as [p q].
    destruct p, q; simpl in *.
    reflexivity.
  Defined.

  (** *** Curried version of proving equality of sigma types *)
  Definition path_prod {A B : Type} (u v : prod A B)
             (p : fst u = fst v) (q : snd u = snd v)
    : u = v
    := path_prod_uncurried u v (pair p q).

  (** *** Equivalence of equality of [prod] with a [prod] of equality *)
  (** We could actually use [IsIso] here, but for simplicity, we
      don't.  If we wanted to deal with proofs of equality of × types
      in dependent positions, we'd need it. *)
  Definition path_prod_uncurried_iff {A B}
             (u v : @prod A B)
    : u = v <-> (prod (fst u = fst v) (snd u = snd v)).
  Proof.
    split; [ intro; subst; split; reflexivity | apply path_prod_uncurried ].
  Defined.

  (** *** Eta-expansion of [@eq (prod _ _)] *)
  Definition path_prod_eta {A B} {u v : @prod A B} (p : u = v)
    : p = path_prod_uncurried u v (fst_path p, snd_path p).
  Proof. destruct u, p; reflexivity. Defined.

  (** *** Induction principle for [@eq (prod _ _)] *)
  Definition path_prod_rect {A B} {u v : @prod A B} (P : u = v -> Type)
             (f : forall p q, P (path_prod_uncurried u v (p, q)))
    : forall p, P p.
  Proof. intro p; specialize (f (fst_path p) (snd_path p)); destruct u, p; exact f. Defined.
  Definition path_prod_rec {A B u v} (P : u = v :> @prod A B -> Set) := path_prod_rect P.
  Definition path_prod_ind {A B u v} (P : u = v :> @prod A B -> Prop) := path_prod_rec P.
End prod.

Lemma prod_iff_and (A B : Prop) : (A /\ B) <-> (A * B).
Proof. repeat (intros [? ?] || intro || split); assumption. Defined.

Global Instance iff_prod_Proper
  : Proper (iff ==> iff ==> iff) (fun A B => prod A B).
Proof. repeat intro; tauto. Defined.
Global Instance iff_iffTp_prod_Proper
  : Proper (iff ==> iffTp ==> iffTp) (fun A B => prod A B) | 1.
Proof.
  intros ?? [?] ?? [?]; constructor; tauto.
Defined.
Global Instance iffTp_iff_prod_Proper
  : Proper (iffTp ==> iff ==> iffTp) (fun A B => prod A B) | 1.
Proof.
  intros ?? [?] ?? [?]; constructor; tauto.
Defined.
Global Instance iffTp_iffTp_prod_Proper
  : Proper (iffTp ==> iffTp ==> iffTp) (fun A B => prod A B) | 1.
Proof.
  intros ?? [?] ?? [?]; constructor; tauto.
Defined.
Global Hint Extern 2 (Proper _ prod) => apply iffTp_iffTp_prod_Proper : typeclass_instances.
Global Hint Extern 2 (Proper _ (fun A => prod A)) => refine iff_iffTp_prod_Proper : typeclass_instances.
Global Hint Extern 2 (Proper _ (fun A B => prod A B)) => refine iff_prod_Proper : typeclass_instances.

(** ** Useful Tactics *)
(** *** [inversion_prod] *)
Ltac simpl_proj_pair_in H :=
  repeat match type of H with
         | context G[fst (pair ?x ?p)]
           => let G' := context G[x] in change G' in H
         | context G[snd (pair ?x ?p)]
           => let G' := context G[p] in change G' in H
         end.
Ltac induction_path_prod H :=
  let H0 := fresh H in
  let H1 := fresh H in
  induction H as [H0 H1] using path_prod_rect;
  simpl_proj_pair_in H0;
  simpl_proj_pair_in H1.
Ltac inversion_prod_step :=
  match goal with
  | [ H : _ = pair _ _ |- _ ]
    => induction_path_prod H
  | [ H : pair _ _ = _ |- _ ]
    => induction_path_prod H
  end.
Ltac inversion_prod := repeat inversion_prod_step.

(** This turns a goal like [x = let v := p in let '(x, y) := f v in x
    + y)] into a goal like [x = fst (f p) + snd (f p)].  Note that it
    inlines [let ... in ...] as well as destructuring lets. *)
Ltac only_eta_expand_and_contract_step :=
  match goal with
  | [ |- context[let '(x, y) := ?e in _] ]
    => rewrite (surjective_pairing e)
  | [ H : context[let '(x, y) := ?e in _] |- _ ]
    => rewrite (surjective_pairing e) in H
  | _ => rewrite <- !surjective_pairing
  | [ H : context[(fst ?e, snd ?e)] |- _ ]
    => rewrite <- !surjective_pairing in H
  end.
Ltac only_eta_expand_and_contract := repeat only_eta_expand_and_contract_step.
Ltac eta_expand :=
  repeat first [ progress cbv beta iota zeta
               | only_eta_expand_and_contract_step ].

(** *** [subst_prod] *)
(** The tactic [subst_prod] is like [subst], but it works on equations
    of the form [_ = (x, y)] and [(x, y) = _] for [x] and [y]
    identifiers. *)
Ltac do_subst_prod A B x y :=
  is_var x; is_var y;
  let H := fresh in
  let xy := fresh x in
  remember (@pair A B x y) as xy eqn:H;
  assert (fst xy = x) by (subst xy; reflexivity);
  assert (snd xy = y) by (subst xy; reflexivity);
  subst x y;
  clear H; try subst xy.
Ltac subst_prod_step :=
  match goal with
  | [ H : _ = @pair ?A ?B ?x ?y |- _ ] => do_subst_prod A B x y
  | [ H : @pair ?A ?B ?x ?y = _ |- _ ] => do_subst_prod A B x y
  end.
Ltac subst_prod := repeat subst_prod_step.
