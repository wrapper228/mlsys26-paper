<INDEPENDENT_ATTACKER>

Провожу полный анализ доказательств. Вот найденные проблемы:

---

### ПРОБЛЕМА 1: Replay Model делает результат о popularity-coupling тривиальным

**ЛОКАЦИЯ:** `appendix_coupling_popularity.tex`, уравнения (eq:replay-sum) и весь "Step 3"

**SEVERITY: WEAK_REJECT**

**СУТЬ:** Доказательство popularity→norm coupling фиксирует последовательность $\{\delta_k\}_{k \geq 1}$ (squared displacements) как **константу** и сравнивает только эффект изменения количества обновлений $N_T$. Авторы явно пишут: *"We do not claim that $\{\delta_k\}$ is invariant under changing the training sampling policy in full SGD dynamics."* Но это превращает результат в тавтологию: "если каждое обновление добавляет фиксированную величину, то больше обновлений = большая сумма."

**ПОЧЕМУ ЭТО ФАТАЛЬНО:** Реальный вопрос — как $\delta_k$ зависит от popularity — остаётся полностью открытым. В реальной SGD динамике:
- $\bar{g}_i$ зависит от batch composition
- Batch composition коррелирует с popularity
- Следовательно, $\|\Delta q_i\|^2 = \delta_k$ может быть **меньше** для popular items (они чаще в негативах → градиенты частично компенсируются)

**КОНТРПРИМЕР:** Рассмотрим item A (popular, probability 0.9) и item B (rare, probability 0.1). По теореме авторов, $E[\|q_A\|^2] \geq E[\|q_B\|^2]$ при условии одинаковых $\{\delta_k\}$. Но если $\delta_k^{(A)} \ll \delta_k^{(B)}$ из-за того, что A часто появляется как негатив и получает "отталкивающие" градиенты, результат может инвертироваться. Авторы не контролируют эту зависимость.

---

### ПРОБЛЕМА 2: Лемма об ортогональности доказана только для одного аргумента косинуса

**ЛОКАЦИЯ:** `appendix_cosine_lemma.tex` — доказано $q^\top \nabla_q \cos(q,k) = 0$. Но статья применяет ортогональность к **item** embeddings $k$.

**SEVERITY: MINOR**

**СУТЬ:** В Appendix B доказывается $\langle q, \nabla_q \cos(q,k) \rangle = 0$ — ортогональность градиента по **первому** аргументу. Но для item tower нужна ортогональность по **второму** аргументу: $\langle k, \nabla_k \cos(q,k) \rangle = 0$. По симметрии это верно, но явно не показано.

**ПОЧЕМУ ЭТО НЕ ФАТАЛЬНО:** Вычисление $\nabla_k \cos(q,k)$ даёт тот же результат по симметрии. Но строгий рецензент может потребовать явного доказательства.

**КОНТРПРИМЕР:** Нет — результат верен, просто неполно изложен.

---

### ПРОБЛЕМА 3: Gap между "$g_i$" и "$\bar{g}_i$" в формулировке теоремы

**ЛОКАЦИЯ:** `orthogonal_motion_summary.tex` говорит о градиенте $g_i$, но в `collinearity.tex` показана коллинеарность с $\bar{g}_i = \frac{1}{c_i}\sum_{j:x_j=x_i} g_j$ (batch-aggregated gradient).

**SEVERITY: MINOR**

**СУТЬ:** Proposition в orthogonal_motion_summary утверждает ортогональность обновления на основе ортогональности "$g_i$". Но для embedding layer с дубликатами в батче обновление коллинеарно $\bar{g}_i$, не индивидуальному $g_i$. Переход $q_i \perp g_j$ для всех $j$ → $q_i \perp \bar{g}_i$ тривиален, но явно не прописан.

**ПОЧЕМУ ЭТО НЕ ФАТАЛЬНО:** Линейность ортогональности: $\langle q_i, \bar{g}_i \rangle = \frac{1}{c_i} \sum_j \langle q_i, g_j \rangle = 0$.

---

### ПРОБЛЕМА 4: "Sufficiently large learning rate" не формализован

**ЛОКАЦИЯ:** `conclusion.tex`, пункт 5; `experiments_orthogonality_popularity_bias.tex`

**SEVERITY: MINOR**

**СУТЬ:** Утверждается, что для наблюдаемого popularity bias требуется "sufficiently large" learning rate, чтобы "overcome random initialization". Но нет формальной характеризации: насколько большой? Относительно чего? Variance инициализации? Dimension?

**ПОЧЕМУ ЭТО НЕ ФАТАЛЬНО:** Это честное эмпирическое наблюдение, не часть формального доказательства. Но ослабляет практическую применимость теории.

---

### ПРОБЛЕМА 5: Условие "SGD without regularization" несовместимо с практикой

**ЛОКАЦИЯ:** `orthogonal_motion_summary.tex`, условие 1

**SEVERITY: MINOR**

**СУТЬ:** Условие требует SGD без weight decay/L2 regularization. Но в эксперименте 10 item tower тренируется с SGD без regularization, а user tower — с Adam **with weight decay**. Авторы утверждают, что это ОК, потому что условия нужны только для item tower. Однако влияние user tower на gradient $g_j$ через InfoNCE loss не анализируется: weight decay на user side меняет $q$, что меняет $\nabla_k \mathcal{L}$.

**ПОЧЕМУ ЭТО НЕ ФАТАЛЬНО:** Ортогональность $\nabla_k \mathcal{L} \perp k$ не зависит от того, как вычислен $q$ — только от того, что loss использует cosine. Так что это ОК.

---

### ПРОБЛЕМА 6: Неявное предположение о независимости batch sampling

**ЛОКАЦИЯ:** `appendix_coupling_popularity.tex`, Step 2

**SEVERITY: MINOR**

**СУТЬ:** "Assume batches are formed by i.i.d. sampling with replacement from a fixed distribution." На практике многие системы используют sampling без replacement, stratified sampling, или динамические negative sampling стратегии (hard negatives). Результат может не выполняться.

**ПОЧЕМУ ЭТО НЕ ФАТАЛЬНО:** Авторы честно ограничивают scope. Но это сужает практическую применимость.

---

### ПРОБЛЕМА 7: Claim "orthogonality breaks" не доказан формально для нелинейных энкодеров

**ЛОКАЦИЯ:** `collinearity.tex`, параграф "Beyond linear encoders" (Section 2.4.1 reference)

**SEVERITY: MINOR**

**СУТЬ:** Утверждается, что для нелинейных энкодеров "non-linearity perturbs $J_i$ in an input- and parameter-dependent way that breaks both the cross-term annihilation (i) and the isotropy (ii)". Но это качественное утверждение без формального доказательства. Показан только counterexample (двухслойный линейный энкодер), но не доказано, что ВСЕ нелинейные энкодеры ломают ортогональность.

**ПОЧЕМУ ЭТО НЕ ФАТАЛЬНО:** Авторы и не претендуют на необходимость. Эмпирические experiments 4-5 демонстрируют отсутствие ортогональности.

---

## ФИНАЛЬНЫЙ ВЕРДИКТ

```
СТАТУС: ОДНА ПРОБЛЕМА УРОВНЯ WEAK_REJECT ОБНАРУЖЕНА.
```

**Главная проблема (WEAK_REJECT):** Replay model в Appendix C слишком слаб для заявленного contribution "formal mechanism linking sampling frequency to norm growth". Фиксация $\{\delta_k\}$ делает результат тривиальным и не переносимым на реальную SGD динамику, где $\delta_k$ зависит от popularity через batch composition.

**Рекомендация:** Либо (a) усилить теоретический результат, показав bounds на $\delta_k$ или их зависимость от popularity, либо (b) ослабить claims в abstract/intro с "formal mechanism" до "partial mechanism under idealized conditions".

---

Остальные проблемы — MINOR: пропущенные мелкие шаги и неполные формулировки, которые не ломают основную логику, но требуют clarification при revision.

</INDEPENDENT_ATTACKER>