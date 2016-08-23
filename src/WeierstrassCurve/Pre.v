Require Import Coq.Classes.Morphisms. Require Coq.Setoids.Setoid.
Require Import Crypto.Algebra.
Require Import Crypto.Util.Tactics.
Require Import Crypto.Util.Notations.
Require Import Crypto.Util.Decidable.

Local Open Scope core_scope.

Generalizable All Variables.
Section Pre.
  Context {F eq zero one opp add sub mul inv div} {field:@field F eq zero one opp add sub mul inv div} {eq_dec: DecidableRel eq}.
  Local Infix "=" := eq. Local Notation "a <> b" := (not (a = b)).
  Local Infix "=" := eq : type_scope. Local Notation "a <> b" := (not (a = b)) : type_scope.
  Local Notation "0" := zero.  Local Notation "1" := one.
  Local Infix "+" := add. Local Infix "*" := mul.
  Local Infix "-" := sub. Local Infix "/" := div.
  Local Notation "- x" := (opp x).
  Local Notation "x ^ 2" := (x*x). Local Notation "x ^ 3" := (x*x^2).
  Local Notation "'∞'" := unit : type_scope.
  Local Notation "'∞'" := (inr tt) : core_scope.
  Local Notation "2" := (1+1). Local Notation "3" := (1+2).
  Local Notation "( x , y )" := (inl (pair x y)).

  Add Field WeierstrassCurveField : (Field.field_theory_for_stdlib_tactic (T:=F)).
  Add Ring WeierstrassCurveRing : (Ring.ring_theory_for_stdlib_tactic (T:=F)).

  Context {a:F}.
  Context {b:F}.

  (* the canonical definitions are in Spec *)
  Definition onCurve (P:F*F + ∞) := match P with
                                    | (x, y) => y^2 = x^3 + a*x + b
                                    | ∞ => True
                                    end.
  Definition unifiedAdd' (P1' P2':F*F + ∞) : F*F + ∞ :=
    match P1', P2' with
    | (x1, y1), (x2, y2)
      => if dec (x1 = x2) then
           if dec (y2 = -y1) then
             ∞
           else ((3*x1^2+a)^2 / (2*y1)^2 - x1 - x1,
                   (2*x1+x1)*(3*x1^2+a) / (2*y1) - (3*x1^2+a)^3/(2*y1)^3-y1)
         else
           ((y2-y1)^2 / (x2-x1)^2 - x1 - x2,
            (2*x1+x2)*(y2-y1) / (x2-x1) - (y2-y1)^3 / (x2-x1)^3 - y1)
    | ∞, ∞ => ∞
    | ∞, _ => P2'
    | _, ∞ => P1'
    end.

  Lemma unifiedAdd'_onCurve : forall P1 P2,
    onCurve P1 -> onCurve P2 -> onCurve (unifiedAdd' P1 P2).
  Proof.
    unfold onCurve, unifiedAdd'; intros [ [x1 y1]|] [ [x2 y2]|] H1 H2;
      break_match; trivial; setoid_subst_rel eq; only_two_square_roots; super_nsatz.
  Qed.
End Pre.
