import PFR.Entropy.Group

/-!
# Ruzsa distance between kernels

## Main definitions

*

## Notations

* `dk[κ ; μ # η ; ν] = `

-/


open Real MeasureTheory

open scoped ENNReal NNReal Topology ProbabilityTheory BigOperators


namespace ProbabilityTheory.kernel

variable {T T' G : Type*}
  [Fintype T] [Nonempty T] [MeasurableSpace T] [MeasurableSingletonClass T]
  [Fintype T'] [Nonempty T'] [MeasurableSpace T'] [MeasurableSingletonClass T']
  [Fintype G] [Nonempty G] [MeasurableSpace G] [MeasurableSingletonClass G]
  [AddCommGroup G] [MeasurableSub₂ G] [MeasurableAdd₂ G]
  {κ : kernel T G} {η : kernel T' G} {μ : Measure T}  {ν : Measure T'}

noncomputable
def rdistm (μ : Measure G) (ν : Measure G) : ℝ :=
    Hm[(μ.prod ν).map (fun x ↦ x.1 - x.2)] - Hm[μ]/2 - Hm[ν]/2

noncomputable
def rdist (κ : kernel T G) (η : kernel T' G) (μ : Measure T) (ν : Measure T') : ℝ :=
  (μ.prod ν)[fun p ↦ rdistm (κ p.1) (η p.2)]

notation3:max "dk[" κ " ; " μ " # " η " ; " μ' "]" => rdist κ η μ μ'

lemma rdist_eq (κ : kernel T G) (η : kernel T' G) (μ : Measure T) (ν : Measure T')
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] :
    dk[κ ; μ # η ; ν] = (μ.prod ν)[fun p ↦ Hm[((κ p.1).prod (η p.2)).map (fun x ↦ x.1 - x.2)]]
      - Hk[κ, μ]/2 - Hk[η, ν]/2 := by
  simp_rw [rdist, rdistm, integral_eq_sum, smul_sub, Finset.sum_sub_distrib, smul_eq_mul]
  congr
  · simp_rw [Fintype.sum_prod_type, ← Finset.sum_mul,
      ← Set.singleton_prod_singleton, Measure.prod_prod, ENNReal.toReal_mul,
      ← Finset.mul_sum, Finset.sum_toReal_measure_singleton, Finset.coe_univ, measure_univ,
      ENNReal.one_toReal, mul_one, mul_div, ← Finset.sum_div, entropy, integral_eq_sum, smul_eq_mul]
  · simp_rw [Fintype.sum_prod_type_right, ← Finset.sum_mul, ← Set.singleton_prod_singleton,
      Measure.prod_prod, ENNReal.toReal_mul, ← Finset.sum_mul, Finset.sum_toReal_measure_singleton,
      Finset.coe_univ, measure_univ, ENNReal.one_toReal, one_mul,
      mul_div, ← Finset.sum_div, entropy, integral_eq_sum, smul_eq_mul]

lemma rdist_eq' (κ : kernel T G) (η : kernel T' G) [IsFiniteKernel κ] [IsFiniteKernel η]
    (μ : Measure T) (ν : Measure T') [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] :
    dk[κ ; μ # η ; ν] =
      Hk[map ((prodMkRight κ T') ×ₖ (prodMkLeft T η)) (fun x ↦ x.1 - x.2) measurable_sub, μ.prod ν]
      - Hk[κ, μ]/2 - Hk[η, ν]/2 := by
  rw [rdist_eq]
  congr with p
  simp only
  rw [map_apply, prod_apply'', prodMkLeft_apply, prodMkRight_apply]

lemma rdist_symm (κ : kernel T G) (η : kernel T' G) [IsFiniteKernel κ] [IsFiniteKernel η]
    (μ : Measure T) (ν : Measure T') [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] :
    dk[κ ; μ # η ; ν] = dk[η ; ν # κ ; μ] := by
  rw [rdist_eq', rdist_eq', sub_sub, sub_sub, add_comm]
  congr 1
  rw [← entropy_comap_swap, comap_map_comm, entropy_sub_comm, Measure.comap_swap, Measure.prod_swap,
    comap_prod_swap, map_map]
  congr

-- $$ H[X,Y,Z] + H[Z] \leq H[X,Z] + H[Y,Z].$$ -/
--lemma entropy_triple_add_entropy_le (κ : kernel T (S × U × V)) [IsMarkovKernel κ]
--    (μ : Measure T) [IsProbabilityMeasure μ] :
--    Hk[κ, μ] + Hk[snd (snd κ), μ] ≤ Hk[deleteMiddle κ, μ] + Hk[snd κ, μ] := by

--$$ H[X,Y,Z] + H[X] \leq H[X,Z] + H[X,Y].$$ -/
--lemma entropy_triple_add_entropy_le' (κ : kernel T (S × U × V)) [IsMarkovKernel κ]
--    (μ : Measure T) [IsProbabilityMeasure μ] :
--    Hk[κ, μ] + Hk[fst κ, μ] ≤ Hk[deleteMiddle κ, μ] + Hk[deleteRight κ, μ] := by

-- `H[X - Y; μ] ≤ H[X - Z; μ] + H[Z - Y; μ] - H[Z; μ]`
-- `κ` is `⟨X,Y⟩`, `η` is `Z`. Independence is expressed through the product `×ₖ`.
lemma ent_of_diff_le (κ : kernel T (G × G)) (η : kernel T G) [IsMarkovKernel κ] [IsMarkovKernel η]
    (μ : Measure T) [IsProbabilityMeasure μ] :
    Hk[map κ (fun p : G × G ↦ p.1 - p.2) measurable_sub, μ]
      ≤ Hk[map ((fst κ) ×ₖ η) (fun p : G × G ↦ p.1 - p.2) measurable_sub, μ]
        + Hk[map ((snd κ) ×ₖ η) (fun p : G × G ↦ p.1 - p.2) measurable_sub, μ]
        - Hk[η, μ] := by
  sorry
  --have h1 : H[⟨X - Z, ⟨Y, X - Y⟩⟩; μ] + H[X - Y; μ] ≤ H[⟨X - Z, X - Y⟩; μ] + H[⟨Y, X - Y⟩; μ] :=
  --  entropy_triple_add_entropy_le μ (hX.sub hZ) hY (hX.sub hY)
  --have h2 : H[⟨X - Z, X - Y⟩ ; μ] ≤ H[X - Z ; μ] + H[Y - Z ; μ] := by
  --  calc H[⟨X - Z, X - Y⟩ ; μ] ≤ H[⟨X - Z, Y - Z⟩ ; μ] := by
  --        have : ⟨X - Z, X - Y⟩ = (fun p ↦ (p.1, p.1 - p.2)) ∘ ⟨X - Z, Y - Z⟩ := by ext1; simp
  --        rw [this]
  --        exact entropy_comp_le μ ((hX.sub hZ).prod_mk (hY.sub hZ)) _
  --  _ ≤ H[X - Z ; μ] + H[Y - Z ; μ] := by
  --        have h : 0 ≤ H[X - Z ; μ] + H[Y - Z ; μ] - H[⟨X - Z, Y - Z⟩ ; μ] :=
  --          mutualInformation_nonneg (hX.sub hZ) (hY.sub hZ) μ
  --        linarith
  --have h3 : H[⟨ Y, X - Y ⟩ ; μ] ≤ H[⟨ X, Y ⟩ ; μ] := by
  --  have : ⟨Y, X - Y⟩ = (fun p ↦ (p.2, p.1 - p.2)) ∘ ⟨X, Y⟩ := by ext1; simp
  --  rw [this]
  --  exact entropy_comp_le μ (hX.prod_mk hY) _
  --have h4 : H[⟨X - Z, ⟨Y, X - Y⟩⟩; μ] = H[⟨X, ⟨Y, Z⟩⟩ ; μ] := by
  --  refine entropy_of_comp_eq_of_comp μ ((hX.sub hZ).prod_mk (hY.prod_mk (hX.sub hY)))
  --    (hX.prod_mk (hY.prod_mk hZ))
  --    (fun p : G × (G × G) ↦ (p.2.2 + p.2.1, p.2.1, -p.1 + p.2.2 + p.2.1))
  --    (fun p : G × G × G ↦ (p.1 - p.2.2, p.2.1, p.1 - p.2.1)) ?_ ?_
  --  · ext1; simp
  --  · ext1; simp
  --have h5 : H[⟨X, ⟨Y, Z⟩⟩ ; μ] = H[⟨X, Y⟩ ; μ] + H[Z ; μ] := by
  --  rw [entropy_assoc hX hY hZ, entropy_pair_eq_add (hX.prod_mk hY) hZ]
  --  exact h
  --rw [h4, h5] at h1
  --calc H[X - Y; μ] ≤ H[X - Z; μ] + H[Y - Z; μ] - H[Z; μ] := by linarith
  --_ = H[X - Z; μ] + H[Z - Y; μ] - H[Z; μ] := by
  --  congr 2
  --  rw [entropy_sub_comm hY hZ]

end ProbabilityTheory.kernel
