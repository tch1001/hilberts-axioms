import organised.congruence.basic
import data.zmod.basic
import data.real.basic
import group_theory.group_action.defs

-- TODO : prove three axioms.
section Fano_example

/-- The Fano Plane. -/
def pts_Fano : Type := {x : zmod 2 × zmod 2 × zmod 2 // x ≠ (0,0,0)}

/--Construction of a Fano plane as an incidence geometry -/
example : incidence_geometry :=
{ pts := pts_Fano,
  lines := { S : set pts_Fano | ∃ y : pts_Fano,
    S = { x | x.1.1 * y.1.1 + x.1.2.1 * y.1.2.1 + x.1.2.2 * y.1.2.2 = 0}},
  I1 := sorry,
  I2 := sorry,
  I3 := sorry
}

end Fano_example


variables u : Type
example {a b c : u} (h : a ≠ b ∨ a ≠ c) : ∃ x : u, x ≠ a :=
begin
  wlog hab : a ≠ b using [b c, c b],
  exact h, use b, exact hab.symm
end

-- affine plane k^2 over a field, modelled as k × k 
section affine_plane

variables {k : Type} [field k] (a b : k × k) (μ₁ μ₂ : k)

lemma temp' : (1 : k) • (b - a) = (b - a) := one_smul _ (b - a)

example (x : k) : (0 : k) • x = (0 : k) * x := rfl

#check @zero_mul -- has_mul.mul 0 x = 0

#check sub_smul

lemma temp'' : μ₁ • (a - b) - μ₂ • (a - b) = (μ₁ - μ₂) • (a - b) :=
begin
  sorry
end

lemma temp''' : μ₁ • (a - b) + μ₂ • (a - b) = (μ₁ + μ₂) • (a - b) :=
begin
  sorry
end

section affine_plane

-- affine plane
def affine_plane (k : Type) [field k] : incidence_geometry :=
{ pts := k × k,
  lines := {S : set (k × k) | ∃ u₀ u : k × k, u ≠ u₀
    ∧ S = {x : k × k | ∃ μ : k, x = u₀ + μ • (u - u₀)} },
  I1 :=
  begin
    intros a b hab,
    use {x : k × k | ∃ μ : k, x = a + μ • (b - a)},
    use [a, b], exact ⟨hab.symm, rfl⟩,
    split, exact ⟨0, by simp⟩,
    split, exact ⟨1, by simp⟩,
    intros l hl hal hbl,
    rcases hl with ⟨u₀, u, huu₀, hl⟩,
    rw hl, ext, simp,
    rw hl at hal hbl,
    cases hal with μ₁ ha, cases hbl with μ₂ hb,
    split; rintros ⟨μ, hx⟩,
    use (μ - μ₁) / (μ₂ - μ₁), rw [ha, hb],
    rw [←sub_sub, ←add_sub, add_comm u₀ (μ₂ • (u - u₀) - u₀), sub_add, sub_self, sub_zero,
      ←sub_smul, smul_smul, div_mul_cancel, add_assoc, ←add_smul, add_comm μ₁ _, sub_add, sub_self,
      sub_zero, hx],
    intro hf, rw sub_eq_zero.1 hf at hb, exact hab (ha.trans hb.symm),
    rw [ha, hb, ←sub_sub, ←add_sub, add_comm u₀ (μ₂ • (u - u₀) - u₀), sub_add, sub_self,
      sub_zero, ←sub_smul, smul_smul, add_assoc, ←add_smul] at hx,
    use μ₁ + μ * (μ₂ - μ₁), rw hx
  end,
  I2 :=
  begin
    rintros l ⟨u₀, u, huu₀, hl⟩,
    rw hl, use [u, u₀],
    exact ⟨huu₀, ⟨1, by simp⟩, ⟨0, by simp⟩⟩
  end,
  I3 :=
  begin
    use [(0, 0), (1, 0), (0, 1)],
    refine ⟨_, _, _, _⟩;
    try {simp only [prod.mk.inj_iff, ne.def, not_false_iff, zero_ne_one, false_and, and_false]},
    rintros ⟨l, hl, hal, hbl, hcl⟩,
    rcases hl with ⟨u₀, u, huu₀, hl⟩,
    rw hl at hal hbl hcl,
    cases hal with μ₁ ha, cases hbl with μ₂ hb,
    have hμ : μ₂ - μ₁ ≠ 0,
      intro hμ, rw sub_eq_zero.1 hμ at hb, rw ←ha at hb, simp at hb, exact hb,
    have h₁ : u - u₀ = (1 / (μ₂ - μ₁), 0),
      calc u - u₀ = (1 / (μ₂ - μ₁)) • (μ₂ • (u - u₀) - μ₁ • (u - u₀))
                  : by rw [←sub_smul, smul_smul, div_mul_cancel 1 hμ, one_smul]
              ... = (1 / (μ₂ - μ₁)) • ((1, 0) - (0, 0)) : by {rw [ha, hb], simp}
              ... = (1 / (μ₂ - μ₁), 0) : by simp,
    have h₂ : u₀ = (-μ₁ / (μ₂ - μ₁), 0),
      calc u₀ =  (0, 0) - μ₁ • (u - u₀) : by rw [ha, add_sub_cancel]
          ... = (-μ₁ / (μ₂ - μ₁), 0)    
              : by {rw h₁, simp, rw [inv_eq_one_div, ←mul_div_assoc, neg_div, mul_one]},
    cases hcl with μ₃ hc,
    rw [h₁, h₂] at hc, simp at hc, exact hc
  end
} 

end affine_plane
namespace r_squared

def is_between (a b c : ℝ × ℝ) : Prop :=
--b ≠ c ∧ ∃ k : ℝ, 0 < k ∧ (a - b) = k • (b - c)
b ≠ c ∧ ∃ k : ℝ, 0 < k ∧ a + k • c = k • b + b

namespace is_between

variables {a b c : ℝ × ℝ}

example : module ℝ (ℝ × ℝ) := infer_instance

lemma one_ne_two (h : is_between a b c) : a ≠ b :=
begin
  rintro rfl,
  rcases h with ⟨hac, k, hkpos, hk⟩,
  rw [add_comm, add_right_cancel_iff] at hk,
  exact hac (smul_left_injective _ hkpos.ne.symm hk.symm),
end

lemma symm (h : is_between a b c) : is_between c b a :=
⟨h.one_ne_two.symm, begin
  -- guess it's 1/k?
  sorry
end⟩

end is_between

/--Construction of ℝ × ℝ as an incidence order geometry and a Hilbert plane -/
def r_squared : incidence_order_geometry :=
{ is_between := is_between,
  B1 :=
  begin
    rintros a b c (h : r_squared.is_between a b c),
    split,
      split,
        exact h.one_ne_two.symm,
    -- rcases h with ⟨hab, k, hk, h⟩,
    -- split, split,
    -- intro hf, rw hf at h, simp at h,
    -- split, use 1 / k,
    -- split, exact one_div_neg.2 hk,
    -- split, rw [←h, smul_smul, one_div_mul_cancel, one_smul],
    -- exact ne_of_lt hk,
    -- cases h, exact (ne_of_lt hk) h, rw (sub_eq_zero.1 h) at hab, exact hab rfl,
    -- split, intro hf, rw hf at hab, exact hab rfl,
    -- have : c ≠ b,
    --   intro hf, rw hf at h, simp at h,
    --   cases h, exact (ne_of_lt hk) h,
    --   exact hab (sub_eq_zero.1 h),
    -- split,
    -- intro hf, rw hf at h, simp at h,
    -- have : k = 1,
    --   rw ←sub_eq_zero,
    --   --have : (k - 1) • (c - b) = 0,
    --   sorry,
    -- sorry,
    -- split, exact this.symm,
    -- use {x : ℝ × ℝ | ∃ μ : ℝ, x = b + μ • (a - b)},
    -- use [b, a], exact ⟨hab, rfl⟩,
    -- split, exact ⟨1, by simp⟩, split, exact ⟨0, by simp⟩,
    -- use k, simp at h, rw h, simp
  end,
  B2 :=
  begin
    intros a b hab,
    sorry,
    --use [b - a + b, -1],
  end,
  B3 :=
  begin
    intros a b c l hl habcl,
    rcases hl with ⟨u₀, u, huu₀, hl⟩,
    rw hl at habcl,
    sorry,
  end,
  B4 :=
  begin
    sorry,
  end,
  ..affine_plane ℝ}

example : hilbert_plane :=
{ segment_congr := sorry,
  C1 := sorry,
  C2 := sorry,
  C3 := sorry,
  angle_congr := sorry,
  C4 := sorry,
  C5 := sorry,
  C6 := sorry,
  ..r_squared }

end r_squared