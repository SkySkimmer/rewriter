Require Import Crypto.ModularArithmetic.ModularBaseSystem.
Require Import Crypto.ModularArithmetic.ModularBaseSystemOpt.
Require Import Crypto.ModularArithmetic.PseudoMersenneBaseParams.
Require Import Crypto.ModularArithmetic.PseudoMersenneBaseParamProofs.
Require Import Coq.Lists.List Crypto.Util.ListUtil.
Require Import Crypto.ModularArithmetic.PrimeFieldTheorems.
Require Import Crypto.ModularArithmetic.ModularBaseSystemInterface.
Require Import Crypto.Tactics.VerdiTactics.
Require Import Crypto.BaseSystem.
Require Import Crypto.Util.ZUtil.
Require Import Crypto.Util.Notations.
Require Import Crypto.Algebra.
Import ListNotations.
Require Import Coq.ZArith.ZArith Coq.ZArith.Zpower Coq.ZArith.ZArith Coq.ZArith.Znumtheory.
Local Open Scope Z.
Local Infix "<<" := Z.shiftr.
Local Infix "&" := Z.land.

(* BEGIN PseudoMersenneBaseParams instance construction. *)

Definition modulus : Z := 2^130 - 5.
Lemma prime_modulus : prime modulus. Admitted.
Definition int_width := 32%Z.

Instance params1305 : PseudoMersenneBaseParams modulus.
  construct_params prime_modulus 5%nat 130.
Defined.

Definition mul2modulus := Eval compute in (construct_mul2modulus params1305).

Instance subCoeff : SubtractionCoefficient modulus params1305.
  apply Build_SubtractionCoefficient with (coeff := mul2modulus).
  cbv; auto.
  cbv [ModularBaseSystem.decode].
  apply ZToField_eqmod.
  cbv; reflexivity.
Defined.

Definition freezePreconditions1305 : freezePreconditions params1305 int_width.
Proof.
  constructor; compute_preconditions.
Defined.

(* END PseudoMersenneBaseParams instance construction. *)

(* Precompute k and c *)
Definition k_ := Eval compute in k.
Definition c_ := Eval compute in c.
Definition k_subst : k = k_ := eq_refl k_.
Definition c_subst : c = c_ := eq_refl c_.

Definition fe1305 : Type := Eval cbv in fe.

Local Opaque Z.shiftr Z.shiftl Z.land Z.mul Z.add Z.sub Let_In phi.



Definition add_formula_sig (f0 f1 f2 f3 f4 g0 g1 g2 g3 g4: Z) :
  { fg | fg = ModularBaseSystemInterface.add (f0,f1,f2,f3,f4) (g0,g1,g2,g3,g4) }.
Proof.
  eexists.
  cbv.
  reflexivity.
Defined.

Definition add_formula_correct := Eval cbv [proj2_sig] in
(fun f0 f1 f2 f3 f4 g0 g1 g2 g3 g4 => proj2_sig (add_formula_sig f0 f1 f2 f3 f4 g0 g1 g2 g3 g4)).

Definition add (f g : fe1305) : fe1305 := Eval cbv beta iota delta [proj1_sig add_formula_sig] in 
  let (f03, f4) := f   in
  let (f02, f3) := f03 in
  let (f01, f2) := f02 in
  let (f0, f1)  := f01 in
  let (g03, g4) := g   in
  let (g02, g3) := g03 in
  let (g01, g2) := g02 in
  let (g0, g1)  := g01 in
  proj1_sig (add_formula_sig f0 f1 f2 f3 f4 g0 g1 g2 g3 g4).

Definition add_correct f g : add f g = ModularBaseSystemInterface.add f g.
Proof.
  cbv [fe1305] in *.
  repeat match goal with [p : (_*Z)%type |- _ ] => destruct p end.
  rewrite <-add_formula_correct.
  reflexivity.
Qed.

Definition sub_formula_sig (f0 f1 f2 f3 f4 g0 g1 g2 g3 g4: Z) :
  { fg | fg = ModularBaseSystemInterface.sub (f0,f1,f2,f3,f4) (g0,g1,g2,g3,g4) }.
Proof.
  eexists.
  cbv.
  reflexivity.
Defined.

Definition sub_formula_correct := Eval cbv [proj2_sig] in
(fun f0 f1 f2 f3 f4 g0 g1 g2 g3 g4 => proj2_sig (sub_formula_sig f0 f1 f2 f3 f4 g0 g1 g2 g3 g4)).

Definition sub (f g : fe1305) : fe1305 := Eval cbv beta iota delta [proj1_sig sub_formula_sig] in 
  let (f03, f4) := f   in
  let (f02, f3) := f03 in
  let (f01, f2) := f02 in
  let (f0, f1)  := f01 in
  let (g03, g4) := g   in
  let (g02, g3) := g03 in
  let (g01, g2) := g02 in
  let (g0, g1)  := g01 in
  proj1_sig (sub_formula_sig f0 f1 f2 f3 f4 g0 g1 g2 g3 g4).

Definition sub_correct f g : sub f g = ModularBaseSystemInterface.sub f g.
Proof.
  cbv [fe1305] in *.
  repeat match goal with [p : (_*Z)%type |- _ ] => destruct p end.
  rewrite <-sub_formula_correct.
  reflexivity.
Qed.

Definition mul_formula_sig (f0 f1 f2 f3 f4 g0 g1 g2 g3 g4: Z) :
  { fg | fg = ModularBaseSystemInterface.mul (k_ := k_) (c_ := c_) (f0,f1,f2,f3,f4) (g0,g1,g2,g3,g4) }.
Proof.
  eexists.
  cbv.
  autorewrite with zsimplify.
  reflexivity.
Defined.

Definition mul_formula_correct := Eval cbv [proj2_sig] in
(fun f0 f1 f2 f3 f4 g0 g1 g2 g3 g4 => proj2_sig (mul_formula_sig f0 f1 f2 f3 f4 g0 g1 g2 g3 g4)).

Definition mul (f g : fe1305) : fe1305 := Eval cbv beta iota delta [proj1_sig mul_formula_sig] in 
  let (f03, f4) := f   in
  let (f02, f3) := f03 in
  let (f01, f2) := f02 in
  let (f0, f1)  := f01 in
  let (g03, g4) := g   in
  let (g02, g3) := g03 in
  let (g01, g2) := g02 in
  let (g0, g1)  := g01 in
  proj1_sig (mul_formula_sig f0 f1 f2 f3 f4 g0 g1 g2 g3 g4).

Definition mul_correct f g : mul f g = ModularBaseSystemInterface.mul (k_ := k_) (c_ := c_) f g.
Proof.
  cbv [fe1305] in *.
  repeat match goal with [p : (_*Z)%type |- _ ] => destruct p end.
  rewrite <-mul_formula_correct.
  reflexivity.
Qed.

Import Morphisms.

Lemma field1305 : @field fe eq zero one opp add sub mul inv div.
Proof.
  pose proof Equivalence_Reflexive.
  eapply (Field.equivalent_operations_field (fieldR := modular_base_system_field k_subst c_subst)).
  Grab Existential Variables.
  + reflexivity.
  + reflexivity.
  + reflexivity.
  + intros; rewrite mul_correct; reflexivity.
  + intros; rewrite sub_correct; reflexivity.
  + intros; rewrite add_correct; reflexivity.
  + reflexivity.
  + reflexivity.
Qed.

(*
Local Transparent Let_In.
Eval cbv iota beta delta [proj1_sig mul Let_In] in (fun f0 f1 f2 f3 f4  g0 g1 g2 g3 g4 => proj1_sig (mul (f4,f3,f2,f1,f0) (g4,g3,g2,g1,g0))).
*)

(* TODO: This file should eventually contain the following operations:
   toBytes
   fromBytes
   inv
   opp
   sub
   zero
   one
   eq
*)
