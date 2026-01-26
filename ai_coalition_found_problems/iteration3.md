<ATTACKER_2>

# ATTACKER 2: Неявные допущения и скрытые условия — Iteration 3

Ниже — мои замечания именно в стиле “а что если это условие не выполняется?”, с фокусом на скрытые предпосылки в обновлённой версии статьи `final_tex_paper_in_this_folder_icml26_iteration2`, плюс учёт выводов из `iteration1.md` и `iteration2.md`.

---

### ПРОБЛЕМА 1: “Replay model” в coupling-аппендиксе скрыто предполагает независимость величин апдейтов \(\delta_k\) от sampling policy \(p_i\)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration2/sections/appendix_coupling_popularity.tex`, “Step 3: a clean replay model…”, Eq. (7)–(11), особенно Eq. \(\|q_i^{(T)}\|^2 = \|q_i^{(0)}\|^2 + \sum_{k=1}^{N_T^{(p_i)}} \delta_k\)
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Последовательность инкрементов \(\{\delta_k\}\) можно считать “фиксированной” и одинаковой при разных \(p_i\); то есть менять \(p_i\) можно, не меняя распределение/траекторию величин апдейтов item’а.
ГДЕ ИСПОЛЬЗУЕТСЯ:
- В переходе от monotone coupling для \(N_T^{(p)}\) к монотонности \(\mathbb{E}[\|q_i^{(T)}\|^2]\) по \(p_i\) через монотонность \(f(n)=\|q_i^{(0)}\|^2+\sum_{k\le n}\delta_k\).
КОНТРПРИМЕР:
- В реальном InfoNCE \(\delta_k=\|\Delta q_i\|^2\) зависит от состава батча (негативов) и от состояния остальных эмбеддингов/модели; изменение \(p_i\) меняет и распределение “других” объектов (из-за нормировки распределения), и частоты встречаемости hard negatives, и динамику user tower → тем самым меняется и \(\delta_k\). Тогда сравнение “только через счётчик апдейтов” перестаёт отражать реальную SGD-динамику.

---

### ПРОБЛЕМА 2: В “Step 2” считается число батчей, где item появился ≥1 раз, но не число вхождений item в батче — скрытое предположение “один апдейт на батч” или “без дубликатов”
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration2/sections/appendix_coupling_popularity.tex`, Eq. \(\pi(p_i)=1-(1-p_i)^B\) и \(N_T^{(p)}\sim\mathrm{Binomial}(T,\pi(p))\)
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Обновление item’а в SGD эквивалентно событию “item встретился хотя бы раз в батче” (а не зависит от кратности вхождений внутри батча), либо дубликаты невозможны.
ГДЕ ИСПОЛЬЗУЕТСЯ:
- В определении “update count” \(N_T^{(p)}\), на котором строится весь coupling механизма.
КОНТРПРИМЕР:
- Для embedding-layer с повторениями item’а в батче обновление на самом деле агрегирует сумму градиентов по всем вхождениям, то есть величина шага и даже “число эффективных апдейтов” зависит от count. При sampling with replacement и больших \(p_i\) дубликаты в батче — нормальны, и модель “≥1 появление = один апдейт” систематически искажает популярностный эффект.

---

### ПРОБЛЕМА 3: В `collinearity.tex` снова неявно требуется “все вхождения item в батче дают один и тот же градиент” (или “в батче нет повторов”)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration2/sections/collinearity.tex`, абзац “Single embedding layer”, вывод \(\Delta q_i = -\eta\,c_i\,g_i\)
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: При \(c_i>1\) градиенты по всем вхождениям item’а одинаковы и равны одному \(g_i\), так что сумму можно заменить на \(c_i g_i\); либо предполагается \(c_i\in\{0,1\}\) (нет дублей).
ГДЕ ИСПОЛЬЗУЕТСЯ:
- В переходе “градиент ортогонален ⇒ апдейт коллинеарен градиенту ⇒ апдейт ортогонален эмбеддингу”.
КОНТРПРИМЕР:
- В InfoNCE разные вхождения item’а в батче имеют разные контексты (разные пары/негативы), поэтому \(g\) зависит от slot’а. Корректно писать \(\Delta q_i=-\eta\sum_{j:x_j=x_i} g_j\). Без этого формально “коллинеарность” в таком виде не доказана, а значит и переход к строгой ортогональности шага становится условным.

---

### ПРОБЛЕМА 4: “Строгая ортогональность” фактически требует идеализированного cosine без \(\varepsilon\)-стабилизации/клиппинга и без stop-grad на норме
ЛОКАЦИЯ:
- `final_tex_paper_in_this_folder_icml26_iteration2/sections/introduction.tex`: определение \(\cos(q,k)=\langle q,k\rangle/(\|q\|\,\|k\|)\)
- `.../sections/appendix_cosine_lemma.tex` и `.../sections/cosine_gradient_orthogonality.tex`: использование ортогональности градиента cosine
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Реализованный в обучении cosine совпадает с математическим определением; нет \(\|q\|_\varepsilon=\sqrt{\|q\|^2+\varepsilon}\), clamp норм, mixed-precision артефактов, нормализации с защитами от нуля и пр.
ГДЕ ИСПОЛЬЗУЕТСЯ:
- В утверждениях вида “strictly orthogonal embedding movements” и в равенстве Пифагора на шаге (как строгом равенстве, а не приближении).
КОНТРПРИМЕР:
- При \(\varepsilon\)-стабилизации (стандартная инженерная практика) градиент уже не обязан быть ортогонален \(q\) ровно, и \(\|q\|^2\) может уменьшаться/колебаться (пусть и с малым дрейфом). Тогда строгость “монотонного роста при каждом апдейте” теряет формальную силу.

---

### ПРОБЛЕМА 5: Скрытое условие \(\|q\|>0\), \(\|k\|>0\) не поднято в основные предпосылки (деление на ноль)
ЛОКАЦИЯ:
- `final_tex_paper_in_this_folder_icml26_iteration2/sections/appendix_cosine_lemma.tex`: “For any nonzero \(q,k\)”
- `.../sections/appendix_cosine_gradient_magnitude.tex`: определения \(\hat q=q/\|q\|\), \(\hat k=k/\|k\|\)
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Все эмбеддинги, участвующие в loss, имеют ненулевую норму на всём протяжении обучения (и при инициализации).
ГДЕ ИСПОЛЬЗУЕТСЯ:
- Везде, где есть нормализация и деление на \(\|q\|\|k\|\).
КОНТРПРИМЕР:
- Padding/спец-токены/фильтрация items иногда реализуются нулевыми строками; либо регуляризация/клиппинг может “прижать” вектор к нулю. Тогда леммы и формулы становятся не определены и требуются отдельные оговорки.

---

### ПРОБЛЕМА 6: “i.i.d. sampling from a fixed distribution” в coupling-части скрыто означает sampling with replacement по слотам батча и независимость по времени
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration2/sections/appendix_coupling_popularity.tex`, Step 2 (i.i.d. sampling, \(\pi(p_i)=1-(1-p_i)^B\))
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Внутри батча слоты независимы и одинаково распределены (with replacement), и распределение не меняется по шагам \(t\).
ГДЕ ИСПОЛЬЗУЕТСЯ:
- В биномиальной модели \(N_T^{(p)}\sim\mathrm{Binomial}(T,\pi(p))\) и в “standard Bernoulli coupling”.
КОНТРПРИМЕР:
- Sampling without replacement внутри эпохи, hard-negative mining, streaming/curriculum, зависимости от истории (например, “не повторять только что показанные”) → \(\pi(p)\) и биномиальная модель становятся неверными, а coupling-разбор неприменим как “production expectation”.

---

### ПРОБЛЕМА 7: “Популярность” в теории — это \(p_i\) sampling policy, а не обязательно истинная частота в данных (терминологическое скрытое отождествление)
ЛОКАЦИЯ:
- `final_tex_paper_in_this_folder_icml26_iteration2/sections/appendix_coupling_popularity.tex`: Step 2
- `.../sections/experiments_orthogonality_popularity_bias.tex`: популярность как “training frequency”
SEVERITY: MINOR
НЕЯВНОЕ ДОПУЩЕНИЕ: Training frequency \(\approx p_i\) (sampling совпадает с “сырой” частотой), хотя на практике sampling часто намеренно дебайсится.
ГДЕ ИСПОЛЬЗУЕТСЯ:
- В интерпретации механизма как “popularity bias” про данные, а не про policy.
КОНТРПРИМЕР:
- Downsample head / upsample tail / importance sampling: тогда норма будет коррелировать с effective \(p_i\), а не с “популярностью” в логах.

---

## ИТОГОВЫЙ СТАТУС
СТАТУС: НЕ ЧИСТО. Критические скрытые предпосылки уровня WEAK_REJECT остаются.

Главное: в iteration2 автор честно ушёл от некорректного pathwise dominance к “механизму”, но в формулировках (включая `collinearity.tex` и replay-идею \(\delta_k\)) остались скрытые условия, которые легко “ломают” заявленную причинную цепочку в реальной SGD-динамике.

</ATTACKER_2>
# ATTACKER 1: Логические дыры в доказательствах — Iteration 3

**Rejection rate: 80%. Репутация: нахожу фатальные логические дыры, которые другие пропускают.**

---
<ATTACKER_1>

## ОЦЕНКА ИЗМЕНЕНИЙ В ITERATION 2

**Радикальная переработка coupling-аргумента:**
- ✅ Удалены проблемные леммы "Expected Gap is Nonnegative" и "Eventual Dominance"
- ✅ Удалены appendix_note_on_batch_difference.tex, appendix_note_on_c_variability.tex, appendix_note_on_distributions.tex
- ✅ Введён чистый "replay model" с честным признанием ограничений
- ✅ Claim ослаблен с "formal proof" до "mechanism"

**Регрессия:**
- ⚠️ В collinearity.tex ОТКАТИЛИ исправление формулы обновления (снова $\Delta q_i = -\eta c_i g_i$ вместо суммы по слотам)

---

## АНАЛИЗ НОВОГО COUPLING-АРГУМЕНТА

### Структура доказательства (appendix_coupling_popularity.tex)

**Step 1:** Под четырьмя условиями Section 2 каждое обновление ортогонально:
$$s_{t+1} = s_t + \|\Delta q_i^{(t)}\|^2, \quad \|\Delta q_i^{(t)}\|^2 \geq 0$$

**Step 2:** $N_T^{(p)} \sim \text{Binomial}(T, \pi(p))$ — количество обновлений. Для $p'_i < p''_i$ можно coupling так, что $N_T^{(p''_i)} \geq N_T^{(p'_i)}$ a.s.

**Step 3 (Replay Model):**
$$\|q_i^{(T)}\|^2 = \|q_i^{(0)}\|^2 + \sum_{k=1}^{N_T^{(p_i)}} \delta_k$$

где $\{\delta_k\}$ — **фиксированная** последовательность неотрицательных инкрементов.

**Ключевое ограничение** (строки 48-51):
> "To turn this mechanism into an unconditional statement about the full SGD dynamics without fixing the sequence $\{\delta_k\}$, one needs additional control of how update magnitudes depend on the training trajectory; this lies outside the four assumptions of Section~2 and is **therefore not claimed here**."

### Вердикт: КОРРЕКТНО В РАМКАХ REPLAY MODEL

**Почему это теперь работает:**
1. В replay model $\{\delta_k\}$ фиксированы — нет проблемы с разными $c$ в разных runs
2. Coupling только по количеству обновлений $N_T^{(p)}$, не по величинам
3. Функция $f(n) = \sum_{k=1}^n \delta_k$ монотонна в $n$ (поскольку $\delta_k \geq 0$)
4. $N_T^{(p'')} \geq N_T^{(p')}$ a.s. ⟹ $f(N_T^{(p'')}) \geq f(N_T^{(p')})$ a.s.

**Почему это честно:**
Авторы **явно признают**, что это "mechanism", а не полное доказательство для реальной динамики SGD. Раньше (iteration 1) они пытались доказать строгое pathwise dominance с разными $c$, что было некорректно. Теперь они правильно ослабили claim.

---

## ПРОБЛЕМА 1: Регрессия — формула обновления в collinearity.tex

### ЛОКАЦИЯ:
Section 2.4 (collinearity.tex), строки 29-32

### SEVERITY: WEAK_REJECT

### СУТЬ:
В iteration 1 формула была исправлена на:
$$\Delta q_i = -\eta \sum_{j: x_j = x_i} g_j$$

В iteration 2 **откатили** к старой неточной формуле:
$$\Delta q_i = -\eta c_i g_i$$

где $c_i$ — число вхождений $x_i$ в батч.

### ПОЧЕМУ ЭТО ПРОБЛЕМА:
При $c_i > 1$ (один item появляется несколько раз в батче), разные вхождения имеют **разные** градиенты $g_j$, потому что они зависят от paired item на другой башне. Запись $c_i g_i$ подразумевает, что все $g_j$ одинаковы, что неверно.

### КОНТРПРИМЕР:
Пусть item $v$ появляется в батче дважды:
- В паре (user $u_1$, item $v$): градиент $g_{j_1}$
- В паре (user $u_2$, item $v$): градиент $g_{j_2}$

Правильно: $\Delta q_v = -\eta (g_{j_1} + g_{j_2})$

В статье написано: $\Delta q_v = -\eta \cdot 2 \cdot g_i$ — где $g_i$ это что? Градиент какого из двух примеров?

### ПОЧЕМУ ЭТО НЕ ФАТАЛЬНО:
Ортогональность сохраняется: если $g_{j_1} \perp q_v$ и $g_{j_2} \perp q_v$, то $(g_{j_1} + g_{j_2}) \perp q_v$.

### ИСПРАВЛЕНИЕ:
Вернуть формулу iteration 1:
$$\Delta q_i = -\eta \sum_{j: x_j = x_i} g_j$$
с пояснением: "Since each $g_j \perp q_i$, their sum is also orthogonal to $q_i$."

---

## ПРОБЛЕМА 2: Индексация batch-slot vs item-id по-прежнему смешана

### ЛОКАЦИЯ:
- one_formula.tex, строки 10-11: "$g_j$ loss gradient w.r.t. the encoder output $q_j$ for the **$j$-th example in the batch**"
- norm_growth_vs_popularity.tex: "$q_i^{(t)}$" как **item embedding**
- collinearity.tex: "$\Delta q_i$" — то ли batch-slot, то ли item-id

### SEVERITY: MINOR

### СУТЬ:
Индекс $i$ (или $j$) используется одновременно как:
1. Индекс примера в батче (batch-slot)
2. Item identity

Это создаёт формальную неоднозначность, особенно при анализе формулы $\Delta q_i = -\eta \sum_j J_i J_j^\top g_j$.

### ИСПРАВЛЕНИЕ:
Ввести разные индексы: $b$ для batch slots, $v$ для item-id.

---

## ПРОБЛЕМА 3: "Claim" в norm_growth_vs_popularity.tex — неформальный

### ЛОКАЦИЯ:
norm_growth_vs_popularity.tex, строки 11-13

### SEVERITY: MINOR

### СУТЬ:
Утверждение "The larger the embedding norm, the slower it grows under a cosine-based loss" подано как неформальный **Claim** без кванторов ($\|q\| > 0$?) и точного определения "slower".

### ИСПРАВЛЕНИЕ:
Оформить как **Lemma**:
> **Lemma.** Let $L(q) = F(\cos(q, k_1), \ldots, \cos(q, k_m))$ with differentiable $F$ and $k_i \neq 0$. For $\|q\| > 0$: $\|\nabla_q L(q)\| = \|Pu\|/\|q\|$, where $\|Pu\|$ is independent of $\|q\|$.

---

## ПРОБЛЕМА 4: Условие $\|q\| > 0$ не указано явно

### ЛОКАЦИЯ:
- appendix_cosine_gradient_magnitude.tex: формулы с $\hat{q} = q/\|q\|$
- appendix_coupling_popularity.tex: динамика $s_t$

### SEVERITY: MINOR

### СУТЬ:
Все формулы требуют $\|q\| > 0$, но это нигде не указано как явное условие.

### ИСПРАВЛЕНИЕ:
Добавить в начало Section 3 или Theorem: "We assume $\|q_i^{(0)}\| > 0$ for all items (satisfied by standard random initialization)."

---

## ПРОБЛЕМА 5: Перегрузка символа $c$

### ЛОКАЦИЯ:
- collinearity.tex, строка 29: $c_i$ = count в батче
- appendix_cosine_gradient_magnitude.tex, строка 41: $c_i(q) = \cos(q, k_i)$

### SEVERITY: MINOR

### СУТЬ:
Символ $c$ используется для двух разных величин: count и cosine similarity.

### ИСПРАВЛЕНИЕ:
Переименовать: $n_i$ для counts, оставить $c_i(q)$ для cosines.

---

## ПРОБЛЕМА 6: Boxed equality после "linearize" без first-order пометки

### ЛОКАЦИЯ:
one_formula.tex, строки 33-35

### SEVERITY: MINOR

### СУТЬ:
Строка 33: "we linearize the encoder around the current parameters and obtain"
Строка 35: boxed equality $\Delta q_i = J_i \Delta\theta$

Для general encoders это приближение ($\approx$), а не равенство. Да, для parameter-linear это точно (сказано в interim_focus.tex), но локально читатель видит "linearize" → "equality".

### ИСПРАВЛЕНИЕ:
Использовать $\approx$ в boxed формуле и добавить: "(Exact equality for parameter-linear encoders, see Section 2.2.)"

---

## ИТОГОВЫЙ СТАТУС

**СТАТУС: СУЩЕСТВЕННО УЛУЧШЕНО. Логических дыр уровня REJECT не обнаружено.**

### Сравнение с предыдущими итерациями:

| Проблема | Iteration 1 | Iteration 1→2 | Iteration 2 |
|----------|-------------|---------------|-------------|
| Coupling: $c' \neq c''$ | REJECT | Переписано | ✅ Решено (replay model) |
| Coupling: non sequitur | REJECT | Удалено | ✅ Решено |
| Coupling: "stays positive" | REJECT | Удалено | ✅ Решено |
| Формула обновления | Исправлено | **РЕГРЕССИЯ** | WEAK_REJECT |
| Индексация | Не исправлено | — | MINOR |
| "Claim" формальность | Не исправлено | — | MINOR |
| $\|q\| > 0$ | Не указано | — | MINOR |
| Перегрузка $c$ | Не исправлено | — | MINOR |

### Резюме:

**Главное достижение iteration 2:** Авторы **честно ослабили claim** с "formal proof of popularity bias" до "mechanism that isolates the contribution of sampling frequency". Это правильное решение — replay model корректен, а попытка доказать полную теорему для SGD динамики была бы нечестной без дополнительных assumptions.

**Главный недостаток:** Регрессия формулы обновления в collinearity.tex. Нужно вернуть исправление iteration 1.

---

## РЕКОМЕНДАЦИИ

### Для финальной версии:

1. **Вернуть исправление формулы обновления** из iteration 1:
   ```latex
   \Delta q_i = -\eta \sum_{j: x_j = x_i} g_j
   ```

2. **Унифицировать индексацию:** batch-slot ($b$) vs item-id ($v$)

3. **Оформить "Claim" как Lemma** с явными условиями

4. **Добавить явное условие** $\|q_i^{(0)}\| > 0$

5. **Переименовать символ $c$** для counts → $n_i$

---

## ВЕРДИКТ

**WEAK ACCEPT (при исправлении регрессии)**

Coupling-аргумент теперь корректен. Авторы честно позиционируют результат как "mechanism", а не как строгую теорему для полной SGD динамики. Это соответствует тому, что можно доказать под четырьмя условиями Section 2.

Проблема регрессии формулы обновления — это WEAK_REJECT уровня, но легко исправляется.

Остальные проблемы — MINOR и не влияют на корректность основных результатов.

---

**Подпись:** ATTACKER 1  
**Вердикт:** WEAK ACCEPT (при условии исправления регрессии в collinearity.tex)

**Примечание:** Это первый раз за три итерации, когда я не нахожу проблем уровня REJECT. Авторы проделали хорошую работу по упрощению доказательства до корректного уровня.

</ATTACKER_1>

<ATTACKER_3>

# ATTACKER 3: Формальная строгость и consistency (iteration 2)

**Роль:** Профессор математики ETH Zürich. Фокус: нотация, кванторы, согласованность определений.

---

## ПРОБЛЕМА 1: Индексация остаётся несогласованной (batch-slot vs item-id)

**ЛОКАЦИЯ:** 
- `one_formula.tex`, строки 10–35
- `collinearity.tex`, строки 29–32
- `norm_growth_vs_popularity.tex`, строки 4–7
- `appendix_coupling_popularity.tex`, строки 7, 21, 30

**SEVERITY:** WEAK_REJECT

**ПРОБЛЕМА:** В `one_formula.tex` (строка 10) определяется "$g_j$ ... for the $j$-th example in the batch", т.е. $j$ — индекс batch-slot. Затем в строке 35 используется $\Delta q_i = J_i \Delta\theta = ...$ без пояснения, что здесь $i$ тоже означает batch-slot (или нет?). Далее:
- В `collinearity.tex` (строка 29): "$c_i$ denotes the number of occurrences of $x_i$ in the batch" — здесь $i$ фактически означает item-id (потому что "number of occurrences of **item** $x_i$")
- В `norm_growth_vs_popularity.tex` (строка 4): "$q_i^{(t)}$" — явно item-embedding (по времени индексированный)
- В `appendix_coupling_popularity.tex` (строка 7): "$q_i^{(t)}$ denote the item embedding" — item-id

Конфликт: один символ $i$ используется и как batch-slot index (в базовых формулах `one_formula`/`collinearity`), и как item-id (в Section 3/coupling). В `appendix_encoders.tex` (строка 4) написано "$x_i = i$ ($x_i$ -- index of example $i$)", что усугубляет путаницу.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The indexing convention is systematically inconsistent: subscript $i$ alternates between batch position (Section 2.1, eq. starting-formula) and item identity (Section 3, Appendix D). This makes $q_i^{(t)}$ and related objects ill-defined across the paper."

**ИСПРАВЛЕНИЕ:** Жёстко развести индексы:
- $b \in \{1, \ldots, B\}$ — batch slot (в `one_formula.tex`: $g_b, J_b$)
- $v \in \{1, \ldots, N\}$ — item-id (в Section 3/coupling: $q_v^{(t)}, s_v^{(t)}$)
- В `collinearity.tex` явно написать, что для item $v$ имеем $\Delta q_v = -\eta \sum_{b: x_b = v} g_b$ (сумма по всем слотам, содержащим item $v$)
- В `appendix_encoders.tex` переписать: "For batch slot $b$, let $x_b \in \{1, \ldots, N\}$ denote the item-id."

---

## ПРОБЛЕМА 2: Формула $\Delta q_i = -\eta c_i g_i$ неверна при дубликатах item в батче

**ЛОКАЦИЯ:** `collinearity.tex`, строки 29–32

**SEVERITY:** WEAK_REJECT

**ПРОБЛЕМА:** В строке 29 вводится "$c_i$ denotes the number of occurrences of $x_i$ in the batch", затем в строке 31 утверждается $\Delta q_i = -\eta c_i g_i$. Это **алгебраически неверно** при $c_i > 1$. Вот почему:

Согласно `one_formula.tex` (строка 10), $g_j$ определён как градиент для $j$-го **примера** батча. Если item $x_i$ появляется в слотах $j_1, j_2, \ldots, j_{c_i}$, то правильная подстановка в формулу \eqref{eq:collinearity-master} даёт:
$$\Delta q_i = -\eta \sum_{j: x_j = x_i} g_j = -\eta (g_{j_1} + g_{j_2} + \cdots + g_{j_{c_i}})$$

Это **сумма** градиентов, а не $c_i \cdot g_i$, потому что каждый $g_{j_k}$ зависит от **своего paired item** на другой башне и обычно **разный**.

В текущей нотации $g_i$ формально означает "градиент для $i$-го примера батча", но в строке 31 авторы трактуют его как "какой-то представительный градиент для item $x_i$", что создаёт подмену объекта.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "Eq. (line 31) states $\Delta q_i = -\eta c_i g_i$, but this is algebraically incorrect. When item $x_i$ appears $c_i > 1$ times in the batch, the correct formula is $\Delta q_i = -\eta \sum_{j: x_j = x_i} g_j$ where each $g_j$ depends on the paired item in that training instance. The symbol $g_i$ is undefined as a per-item gradient."

**ИСПРАВЛЕНИЕ:** 
1. Убрать строки 29–32 с формулой $\Delta q_i = -\eta c_i g_i$
2. Написать корректно: "Substituting \eqref{eq:JJ-embed} into \eqref{eq:collinearity-master}, we obtain $\Delta q_v = -\eta \sum_{b: x_b = v} g_b$ where the sum runs over all batch slots containing item $v$. Since each $g_b \perp q_v$ (by cosine-loss orthogonality), their sum is also orthogonal to $q_v$."
3. Если хочется сохранить множитель $c_v$, ввести **среднее**: "$\bar g_v := \frac{1}{c_v} \sum_{b: x_b = v} g_b$, тогда $\Delta q_v = -\eta c_v \bar g_v$."

---

## ПРОБЛЕМА 3: Перегрузка символа $c$ сохранилась (count vs cosine similarity)

**ЛОКАЦИЯ:**
- `collinearity.tex`, строка 29: $c_i$ = count
- `appendix_cosine_gradient_magnitude.tex`, строки 41–42: $c_i(q) = \cos(q, k_i)$
- `appendix_cosine_gradient_magnitude.tex`, строка 82: $c_i = \hat q^\top \hat k_i$

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Символ $c$ используется для двух разных величин:
1. В `collinearity.tex`: $c_i$ = количество вхождений item $x_i$ в батч
2. В `appendix_cosine_gradient_magnitude.tex`: $c_i(q) = \cos(q, k_i)$ (cosine similarity)

В строке 82 (`appendix_cosine_gradient_magnitude.tex`) используется $c_i = \hat q^\top \hat k_i$, что совпадает с косинусом нормированных векторов, но **конфликтует** с определением $c_i$ как count из `collinearity.tex`.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The symbol $c_i$ is overloaded: it denotes batch count in Section 2.4 (line 29 of collinearity.tex) and cosine similarity in Appendix C (line 41, 82). This creates ambiguity when cross-referencing equations."

**ИСПРАВЛЕНИЕ:** Переименовать одну из величин:
- Для count: $n_v$ (число вхождений item $v$ в батч)
- Для cosine: $\rho_i(q) = \cos(q, k_i)$ или оставить $c_i(q)$ только в Appendix C с явной оговоркой, что это локальная нотация

---

## ПРОБЛЕМА 4: "Claim" в Section 3 остаётся неформальным

**ЛОКАЦИЯ:** `norm_growth_vs_popularity.tex`, строки 11–13

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Ключевое утверждение "The larger the embedding norm, the slower it grows under a cosine-based loss" подано как неформальный **Claim** без:
- Точных кванторов (для каких $q$? $\|q\| > 0$?)
- Формального определения "slower" (производная? норма градиента?)
- Условий на $F$, $k_i$

В proof-heavy статье такие утверждения должны быть оформлены как Lemma/Proposition.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The Claim in Section 3 (lines 11–13) lacks formal statement: no quantifiers, no precise definition of 'slower grows', no conditions on $F$ or $k_i$. For a theorem-style paper, key results require rigorous formulation."

**ИСПРАВЛЕНИЕ:** Переформулировать как Lemma:

> **Lemma (Norm–Growth Inverse Relation).** Let $L(q) = F(\cos(q, k_1), \ldots, \cos(q, k_m))$ where $F$ is differentiable and $k_i \neq 0$ for all $i$. For any $q$ with $\|q\| > 0$:
> $$\|\nabla_q L(q)\| = \frac{\|Pu\|}{\|q\|}$$
> where $P = I - \hat{q}\hat{q}^\top$ and $u = \sum_i (\partial F/\partial c_i) \hat{k}_i$. Since $\|Pu\|$ does not depend on $\|q\|$ (only on direction $\hat{q}$), the gradient norm decreases monotonically as $\|q\|$ increases.

---

## ПРОБЛЕМА 5: Несогласованность нумерации условий (intro vs conclusion)

**ЛОКАЦИЯ:**
- `introduction.tex`, строки 13–15: (A1), (A2), (A3), (A4)
- `conclusion.tex`, строки 4–9: enumerate 1, 2, 3, 4, 5 (без буквенных меток)
- `norm_growth_vs_popularity.tex`, строка 4: "four conditions from Section~2"

**SEVERITY:** MINOR

**ПРОБЛЕМА:** В introduction используется нумерация (A1)–(A4), в conclusion — простой enumerate (1–5), в Section 3 — "four conditions". Это создаёт путаницу при ссылках: непонятно, какой набор канонический.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "Conditions are numbered inconsistently: (A1)–(A4) in Introduction, 1–5 in Conclusion, 'four conditions' in Section 3. Which set is authoritative?"

**ИСПРАВЛЕНИЕ:** Унифицировать нумерацию:
- Либо везде (A1)–(A5)
- Либо разделить: "теоретические (A1)–(A4)" + "практический фактор (A5): sufficiently large learning rate"
- В conclusion использовать ту же нумерацию (A1)–(A5) вместо enumerate

---

## ПРОБЛЕМА 6: "$x_i$ -- index of example $i$" циклично и усугубляет индексную путаницу

**ЛОКАЦИЯ:** `appendix_encoders.tex`, строка 4

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Написано "\textbf{Input:} $x_i = i \in \{1,\dots,N\}$ \;($x_i$ -- index of example $i$)". Это формально означает "$x_i$ is the index of example $i$", что циклично (если $i$ — индекс примера, то "$x_i = i$" означает "input of example $i$ is $i$ itself" — тавтология).

На самом деле авторы хотят сказать: "$x_i$ is the item-id **for** example $i$", но это не следует из текста.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "Appendix A.1, line 4: the phrase '$x_i$ -- index of example $i$' is circular. It should clarify whether $i$ is a batch position or an item identifier."

**ИСПРАВЛЕНИЕ:** Переписать:
> "\textbf{Input:} For training example at batch position $b$, let $x_b \in \{1, \ldots, N\}$ denote the item-id (row index in embedding matrix $E$)."

Либо:
> "\textbf{Input:} $x_i$ is the item identity (an integer in $\{1, \ldots, N\}$) for the training example."

---

## ПРОБЛЕМА 7: "Replay model" в coupling-аппендиксе не определён формально

**ЛОКАЦИЯ:** `appendix_coupling_popularity.tex`, строки 28–37

**SEVERITY:** MINOR

**ПРОБЛЕМА:** В строке 28 вводится термин "replay model" с формулировкой "we treat the nonnegative sequence $\{\delta_k\}_{k \ge 1}$ as fixed". Но:
- Не определено явно, что такое "replay model" как математическая конструкция
- Не объяснено, откуда берётся последовательность $\{\delta_k\}$ (это фиксация одной реализации? среднее? детерминистическая последовательность из другой модели?)
- Связь с полной SGD-динамикой остаётся неявной

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "Appendix D introduces a 'replay model' (line 28) without formal definition. What is the probabilistic status of the sequence $\{\delta_k\}$? How does this relate to the full SGD dynamics claimed in Section 3?"

**ИСПРАВЛЕНИЕ:** Добавить явное определение:
> **Definition (Replay model).** Given a realization of the training process, define $\delta_k := \|\Delta q_i\|^2$ at the $k$-th update of item $i$. The replay model treats $\{\delta_k\}_{k \ge 1}$ as a fixed (non-random) sequence and compares only the effect of changing $N_T^{(p_i)}$ (the update count) by varying $p_i$.

Затем явно оговорить:
> "This isolates the sampling-frequency contribution to norm growth. To extend the result to full SGD dynamics (where $\{\delta_k\}$ depends on the training trajectory), additional control of update magnitudes is needed; see concluding remarks."

---

## ПРОБЛЕМА 8: Параграф "Interpretation" признаёт неполноту результата, но это не отражено в Section 3

**ЛОКАЦИЯ:** `appendix_coupling_popularity.tex`, строки 48–50; `norm_growth_vs_popularity.tex`, строка 17

**SEVERITY:** MINOR

**ПРОБЛЕМА:** В `appendix_coupling_popularity.tex` (строки 49–50) честно написано:
> "To turn this mechanism into an unconditional statement about the full SGD dynamics without fixing $\{\delta_k\}$, one needs additional control... this lies outside the four assumptions... and is therefore not claimed here."

Но в `norm_growth_vs_popularity.tex` (строка 17) сказано:
> "Appendix ... proves that ... the expected squared norm after $T$ batches is nondecreasing in the item's sampling probability."

Это **противоречие**: Appendix D **не доказывает** это для "full SGD dynamics", а только для replay model (фиксированной $\{\delta_k\}$).

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "Section 3 (line 17) claims Appendix D proves monotonicity of expected norm, but Appendix D explicitly limits the result to a 'replay model' (line 49–50). The main text overstates the proved result."

**ИСПРАВЛЕНИЕ:** В `norm_growth_vs_popularity.tex` переформулировать:
> "Appendix~\ref{app:popularity-dependence} formalizes a coupling mechanism that, under the replay model (treating update magnitudes as fixed), proves that expected squared norm is nondecreasing in sampling probability. This isolates the sampling-frequency contribution guaranteed by the four conditions of Section~2."

---

## ПРОБЛЕМА 9: Boxed-равенство после "linearize" не помечено как первое приближение

**ЛОКАЦИЯ:** `one_formula.tex`, строки 33–35

**SEVERITY:** MINOR

**ПРОБЛЕМА:** В строке 33 написано "we linearize the encoder around the current parameters and obtain", затем в строке 35 стоит boxed-равенство. Для general encoders это первое приближение ($\approx$), хотя позже в `interim_focus.tex` поясняется, что для parameter-linear это точно. Но локально читатель видит строгое "=" сразу после "linearize".

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "Equation (starting-formula) is presented as equality immediately after 'we linearize', which is misleading for general encoders. The caveat appears later (Section 2.2), but the boxed equation should indicate first-order approximation."

**ИСПРАВЛЕНИЕ:** Заменить знак равенства на $\approx$ с subscript:
```latex
\boxed{\; \Delta q_{i} \approx J_{i}\,\Delta\theta = -\eta \sum_{j} J_{i}\,J_{j}^{\!\top}\,g_{j} \;}_{\text{first-order}}
```
И сразу ниже добавить: "(Exact equality for parameter-linear encoders; see Section~2.2.)"

---

## ПРОБЛЕМА 10: Отсутствие явных условий $\|q\| > 0$, $\|k\| > 0$ в формулах

**ЛОКАЦИЯ:**
- `appendix_cosine_lemma.tex`, строка 4: "For any nonzero $q, k \in \mathbb{R}^d$"
- `appendix_cosine_gradient_magnitude.tex`, формулы с $\hat q = q/\|q\|$ (строки 20, 42)
- `norm_growth_vs_popularity.tex`, Claim (строки 11–13)

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Формулы требуют $\|q\| > 0$ (для нормализации $\hat q = q/\|q\|$) и $\|k\| > 0$ (для косинуса). В `appendix_cosine_lemma.tex` это явно указано ("nonzero"), но в:
- Claim (Section 3): нет условия
- Appendix C: $\hat q$ используется без проверки $\|q\| > 0$
- Coupling (Appendix D): $s_t = \|q_i^{(t)}\|^2$ подразумевает $\|q\| > 0$, но не оговорено как предпосылка

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "Key formulas (Appendix C, Claim in Section 3) use $\hat q = q/\|q\|$ without stating $\|q\| > 0$ as a condition. For completeness, this should be explicit."

**ИСПРАВЛЕНИЕ:** 
- В Claim/Lemma добавить: "For any $q$ with $\|q\| > 0$ and nonzero $k_i$..."
- В coupling (Appendix D) добавить в начале: "We assume $\|q_i^{(0)}\| > 0$ for all items (satisfied almost surely by standard random initialization)."

---

## ИТОГОВЫЙ СТАТУС

**НЕ ЧИСТО.** Обнаружены проблемы формальной строгости:

**WEAK_REJECT уровня:**
1. Несогласованность индексации (batch-slot vs item-id) — системная проблема
2. Алгебраическая ошибка в формуле $\Delta q_i = -\eta c_i g_i$ при дубликатах

**MINOR уровня:**
3. Перегрузка символа $c$ (count vs cosine)
4. Неформальный "Claim" без кванторов
5. Несогласованность нумерации условий (A1–A4 vs 1–5)
6. Циклическая формулировка "$x_i$ -- index of example $i$"
7. "Replay model" не определён формально
8. Противоречие между Section 3 и Appendix D (scope результата)
9. Boxed-равенство после "linearize" без пометки "$\approx$"
10. Отсутствие явных условий $\|q\| > 0$

**РЕКОМЕНДАЦИЯ:** 
- **Критично:** Исправить индексацию (развести $b$ vs $v$) и формулу в `collinearity.tex` (использовать сумму по слотам)
- **Важно:** Синхронизировать Section 3 и Appendix D по scope результата (replay model vs full dynamics)
- **Желательно:** Унифицировать нотацию ($c$, нумерацию условий), сделать Claim формальным Lemma

**ГЛАВНАЯ ПРОБЛЕМА:** Даже после переработки coupling в "replay model", базовая нотационная несогласованность и алгебраическая неточность в формуле обновления остаются и подрывают формальную корректность доказательной цепочки.

</ATTACKER_3>

<AGGREGATOR SUMMARY>

# КОНСОЛИДИРОВАННЫЙ СПИСОК ПРОБЛЕМ (ITERATION 3)

## КРИТИЧЕСКИЕ (любая из них = reject)
(нет)

## СЕРЬЁЗНЫЕ (накопление = weak reject)
1. Регрессия/некорректность формулы обновления при дубликатах item в батче (\(\Delta q_i=-\eta c_i g_i\) вместо суммы по вхождениям)
   - Источник: Attacker 1 (Проблема 1), Attacker 2 (Проблема 3), Attacker 3 (Проблема 2)
   - Суть: При \(c_i>1\) градиенты по разным вхождениям item’а различаются (зависят от paired контекста), поэтому корректно \(\Delta q_v=-\eta\sum_{b:x_b=v} g_b\); запись \(c_i g_i\) подменяет объект (градиент “по примеру” vs “по item”) и делает выводы формально неверными.
   - Impact: Подрывает строгость цепочки “коллинеарность ⇒ ортогональность шага ⇒ пифагорова динамика” в proof-heavy части; легко используется рецензентом как “Eq. not derived / algebraically incorrect”.

2. Несогласованная индексация (batch-slot vs item-id) остаётся системной и делает обозначения неоднозначными по всей статье
   - Источник: Attacker 3 (Проблема 1), Attacker 1 (Проблема 2), Attacker 2 (Проблема 2 — через трактовку \(N_T\))
   - Суть: В `one_formula.tex` индексы относятся к слотам батча (примеру), а далее \(q_i^{(t)}\) и связанные величины используются как item-id; в `collinearity.tex` одновременно фигурируют определения, завязанные на item occurrences, что конфликтует с “batch-slot” смыслом индексов.
   - Impact: Формальная неоднозначность делает ряд утверждений “ill-defined” и снижает доверие к доказательной части.

3. Coupling-аппендикс в текущем виде опирается на скрытые предпосылки “replay model”, которые не эквивалентны полной SGD-динамике без дополнительных условий
   - Источник: Attacker 2 (Проблема 1), Attacker 3 (Проблемы 7, 8)
   - Суть: В replay model последовательность инкрементов \(\{\delta_k\}\) трактуется как фиксированная/независящая от \(p_i\); но в реальном InfoNCE \(\delta_k=\|\Delta q_i\|^2\) зависит от состава батча, траектории и распределения остальных объектов, которое меняется при изменении \(p_i\). Также “Interpretation” признаёт ограничение, но Section 3 формулирует результат как доказанный в более широком смысле.
   - Impact: Риск “scope overclaim”: механизм валиден в заявленной модели, но текст может быть прочитан как утверждение про full SGD; это тянет на weak reject, если не синхронизировать формулировки/предпосылки.

4. Модель счётчика обновлений \(N_T^{(p)}\) скрыто предполагает “один апдейт на батч”/отсутствие дублей, хотя в реальности кратность вхождений влияет на шаг
   - Источник: Attacker 2 (Проблема 2)
   - Суть: В Step 2 используется вероятность “появился ≥1 раз” и биномиальная модель для числа “обновлений”, но при sampling with replacement и больших \(p_i\) дубликаты типичны, а обновление агрегирует вклад всех вхождений (меняется величина шага и “эффективное число апдейтов”).
   - Impact: Искажает механизм популярностного эффекта и требует либо уточнения модели, либо явного ограничения (например, без повторов/один update per batch).

5. Скрытые предпосылки модели обучения/реализации: “идеальный cosine” без \(\varepsilon\)-стабилизации/клиппинга, строгие \(\|q\|,\|k\|>0\), и “i.i.d.” в сильном смысле (with replacement по слотам + независимость по времени)
   - Источник: Attacker 2 (Проблемы 4, 5, 6), Attacker 2 (Проблема 5), Attacker 3 (Проблема 10)
   - Суть: Строгая ортогональность/пифагорова динамика требует математического cosine без инженерных модификаций; формулы нормализации требуют ненулевых норм; биномиальная модель для \(N_T\) требует независимости по слотам и по времени.
   - Impact: Без явного сужения scope/оговорок это ослабляет применимость и воспринимаемую строгость “production-relevant” утверждений.

## МИНОРНЫЕ (желательно исправить)
1. Перегрузка символа \(c\) (count vs cosine similarity)
   - Источник: Attacker 1 (Проблема 5), Attacker 3 (Проблема 3)
   - Суть: \(c_i\) используется и для counts, и для \(\cos(\cdot)\), что мешает чтению/ссылкам.

2. “Claim” в Section 3 остаётся неформальным (нет кванторов/точного смысла “slower”)
   - Источник: Attacker 1 (Проблема 3), Attacker 3 (Проблема 4)

3. Boxed equality сразу после “linearize” без пометки first-order approximation
   - Источник: Attacker 1 (Проблема 6), Attacker 3 (Проблема 9)

4. Несогласованность нумерации условий (A1–A4 vs 1–5 / “four conditions”)
   - Источник: Attacker 3 (Проблема 5)

5. Цикличная/путающая формулировка “\(x_i\) — index of example \(i\)” в аппендиксе энкодеров
   - Источник: Attacker 3 (Проблема 6)

6. Терминологическая оговорка: “popularity” как \(p_i\) sampling policy, а не обязательно истинная частота в данных
   - Источник: Attacker 2 (Проблема 7)

## ОТКЛОНЁННЫЕ
(нет)

## СТАТУС ИТЕРАЦИИ
- Критических проблем: 0
- Серьёзных проблем: 5
- ВЕРДИКТ: ТРЕБУЕТ ДОРАБОТКИ (coupling-часть стала честнее в рамках replay model, но остаются WEAK_REJECT проблемы: формула обновления при дублях, системная индексация, а также ряд скрытых предпосылок и несинхронизированный scope между Section 3 и Appendix D)

</AGGREGATOR SUMMARY>

<DEFENDER_1>

### ПРОБЛЕМА: Регрессия/некорректность формулы обновления при дубликатах item в батче (\(\Delta q_i=-\eta c_i g_i\) вместо суммы по вхождениям)
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна
- Severity: WEAK_REJECT
- Направление исправления: в `final_tex_paper_in_this_folder_icml26_iteration2/sections/collinearity.tex` заменить вывод для embedding layer на корректное суммирование по вхождениям item в батче:
  - вместо \(\Delta q_i=-\eta c_i g_i\) писать \(\Delta q_v=-\eta\sum_{b:\,x_b=v} g_b\);
  - при желании сохранить “count”-множитель ввести \(\bar g_v:=\frac1{c_v}\sum_{b:\,x_b=v} g_b\) и писать \(\Delta q_v=-\eta c_v \bar g_v\).

---

### ПРОБЛЕМА: Несогласованная индексация (batch-slot vs item-id) остаётся системной и делает обозначения неоднозначными по всей статье
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна
- Severity: WEAK_REJECT
- Направление исправления: развести индексацию во всей статье:
  - \(b\in\{1,\dots,B\}\) — slot/пример батча (где определяются \(g_b,J_b,q_b\) в `one_formula.tex`);
  - \(v\in\{1,\dots,N\}\) — item-id (где живут \(q_v\), \(s_t=\|q_v^{(t)}\|^2\) в Section 3 и Appendix D);
  - явно ввести \(x_b\) как item-id, стоящий в slot \(b\), и переписать формулы так, чтобы не было “одного и того же \(i\)” в разных ролях.

---

### ПРОБЛЕМА: Coupling-аппендикс в текущем виде опирается на скрытые предпосылки “replay model”, которые не эквивалентны полной SGD-динамике без дополнительных условий
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально:
  - Для full-SGD действительно нет теоремы “монотонно по \(p_i\)” без контроля того, как \(\delta_k=\|\Delta q_i\|^2\) меняется с траекторией и с batch composition.
  - Термин “replay model” полезно определить формально (как отдельную модель/конструкцию), иначе рецензент может спросить “что именно фиксируем и в каком смысле?”.
- Что преувеличено:
  - Это не “скрытая” предпосылка: в `final_tex_paper_in_this_folder_icml26_iteration2/sections/appendix_coupling_popularity.tex` прямо сказано, что результат “stated as a mechanism”, и прямо написано, что вывод для full SGD “is therefore not claimed here”.
  - В `final_tex_paper_in_this_folder_icml26_iteration2/sections/norm_growth_vs_popularity.tex` это синхронизировано: там явно стоит “in a replay model” и слово “mechanism”.
- Реальная severity: MINOR / WEAK_REJECT
  - MINOR, если добавить формальное определение “replay model” (и 1–2 предложения, что \(\{\delta_k\}\) понимается как фиксированная неслучайная последовательность);
  - WEAK_REJECT, если где-то в тексте всё ещё остаётся впечатление, что это доказано для full SGD (надо перепроверить абстракт/вклад).

---

### ПРОБЛЕМА: Модель счётчика обновлений \(N_T^{(p)}\) скрыто предполагает “один апдейт на батч”/отсутствие дублей, хотя в реальности кратность вхождений влияет на шаг
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально:
  - Дубликаты item в батче меняют величину шага (и \(\delta_k\)), а вероятность дублей растёт с \(p_i\); это действительно взаимодействует с “frequency–norm” механизмом.
- Что преувеличено:
  - В текущей постановке Appendix D \(N_T^{(p)}\) — это именно число \emph{батчей}, где item появился ≥1 раз; это совместимо с тем, что в одном батче мы делаем один шаг SGD по параметрам, а кратность/состав вхождений “зашиты” в \(\delta_k\).
  - То есть проблема не в “некорректности” \(N_T\), а в том, что читателю нужно явно пояснить: “count внутри батча влияет на \(\delta_k\), и это как раз то, что replay model намеренно не контролирует”.
- Реальная severity: MINOR
- Направление исправления: добавить 2–3 поясняющих строки в Step 2–3 Appendix D: что “update event” = “батч, где item присутствует”, а дубликаты/мультивклад входят в \(\delta_k\).

---

### ПРОБЛЕМА: Скрытые предпосылки модели обучения/реализации: “идеальный cosine” без \(\varepsilon\)-стабилизации/клиппинга, строгие \(\|q\|,\|k\|>0\), и “i.i.d.” в сильном смысле (with replacement по слотам + независимость по времени)
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально:
  - \(\|q\|>0,\|k\|>0\) действительно требуется (в cosine-лемме явно: “For any nonzero \(q,k\)”).
  - Step 2 в Appendix D использует per-slot вероятность и \(\pi(p)=1-(1-p)^B\), т.е. фактически подразумевает sampling with replacement внутри батча и независимость по слотам, плюс “fixed distribution” по времени.
  - Практические \(\varepsilon\)-стабилизации cosine в инженерных реализациях могут разрушать \emph{строгую} ортогональность.
- Что преувеличено:
  - Это не “ошибка теории”, а вопрос аккуратного scope: статья анализирует математическую модель; нужно просто явно вынести допущения в assumptions/remarks, чтобы не возникало ощущения “production claim по умолчанию”.
- Реальная severity: MINOR / WEAK_REJECT (в зависимости от того, насколько агрессивно текст позиционирует “strictly orthogonal” как production-факт).
- Направление исправления: добавить короткие явные предпосылки/оговорки: \(\|q^{(0)}\|>0\), \(\|k\|>0\); i.i.d. sampling with replacement; и ремарку про \(\varepsilon\)-cosine как практическое отклонение (в духе “идеализированная модель”).

---

## ИТОГОВАЯ СВОДКА
ВАЛИДНЫХ: 2 из 5
ТРЕБУЮТ ИСПРАВЛЕНИЯ:
- Регрессия формулы обновления при дублях (в `collinearity.tex`)
- Системная индексация batch-slot vs item-id

МОЖНО ЗАЩИТИТЬ В REBUTTAL:
- Replay model: это явно заявленный scope (но стоит формально определить “replay model” и следить, чтобы нигде не было overclaim про full SGD)
- \(N_T\) и дубликаты: не ломают механизм, но требуют пояснения “дубликаты входят в \(\delta_k\)”
- \(\varepsilon\)-cosine / сильный i.i.d. / \(\|q\|,\|k\|>0\): это assumptions/scope, а не математическая ошибка; лучше поднять в явные оговорки

</DEFENDER_1>


<DEFENDER_2>

# DEFENDER 2: Генератор контраргументов для rebuttal — Iteration 3

**Репутация:** 50+ review cycles на топ-конференциях.

---

## ЧАСТЬ 1: ПРОБЛЕМЫ, ТРЕБУЮЩИЕ ИСПРАВЛЕНИЯ В СТАТЬЕ

---

### ПРОБЛЕМА: Формула $\Delta q_i = -\eta c_i g_i$ некорректна при дубликатах
СТАТУС: Требует исправления в статье, не в rebuttal.

ЧЕРНОВИК REBUTTAL:
"""
We thank the reviewer for catching this algebraic imprecision. When item $v$ appears $c_v > 1$ times in the batch, the correct formula is:
$$\Delta q_v = -\eta \sum_{b: x_b = v} g_b$$
where each $g_b$ depends on the paired item in training instance $b$.

We have corrected Eq. (31) in Section 2.4 to use the sum form. Crucially, the orthogonality result is preserved: since each $g_b \perp q_v$ (by the cosine-loss lemma, Appendix B), their sum is also orthogonal to $q_v$. Thus Proposition 2.6 remains valid.

If one wishes to retain the count notation, we define $\bar{g}_v := \frac{1}{c_v}\sum_{b: x_b = v} g_b$, yielding $\Delta q_v = -\eta c_v \bar{g}_v$ with $\bar{g}_v \perp q_v$.
"""

---

### ПРОБЛЕМА: Несогласованная индексация (batch-slot vs item-id)
СТАТУС: Требует исправления в статье, не в rebuttal.

ЧЕРНОВИК REBUTTAL:
"""
We thank the reviewer for identifying this notational inconsistency. We have revised the manuscript to distinguish:
- $b \in \{1, \ldots, B\}$ — batch slot index (used for $g_b$, $J_b$ in Section 2.1)
- $v \in \{1, \ldots, N\}$ — item identity (used for $q_v^{(t)}$, $s_v^{(t)}$ in Section 3 and Appendix D)

The update formula now reads: $\Delta q_v = -\eta \sum_{b: x_b = v} g_b$, summing over all batch slots containing item $v$. In Appendix A, we clarify: "For batch slot $b$, let $x_b \in \{1, \ldots, N\}$ denote the item-id."
"""

---

## ЧАСТЬ 2: ПРОБЛЕМЫ ДЛЯ ЗАЩИТЫ В REBUTTAL

---

### ПРОБЛЕМА: Replay model не эквивалентен full SGD dynamics (Attacker 2, Проблема 1)

REBUTTAL RESPONSE:
"""
We thank the reviewer for this important observation. The reviewer is correct that in full SGD dynamics, the sequence $\{\delta_k\}$ depends on the training trajectory and batch composition.

**This is exactly why we explicitly restrict the claim to the "replay model" formulation.** In Appendix D (lines 48–51), we state:

> "To turn this mechanism into an unconditional statement about the full SGD dynamics without fixing the sequence $\{\delta_k\}$, one needs additional control of how update magnitudes depend on the training trajectory; this lies outside the four assumptions of Section~2 and is **therefore not claimed here**."

The replay model isolates the **pure contribution of sampling frequency**: given any fixed realization of update magnitudes, more frequent sampling leads to more updates, hence larger accumulated norm. This is a valid mechanism analysis, not a full dynamical theorem.

**Physical interpretation:** The replay model answers: "If I take the same training run and only change how often item $i$ is sampled (keeping all else equal), what happens to its norm?" The answer is: it increases with sampling frequency. This is precisely the popularity bias mechanism under the four conditions.
"""

ТАКТИКА: Redirect + Clarify
- Показать, что ограничение УЖЕ явно указано в тексте
- Объяснить, что replay model — корректный инструмент изоляции фактора

СИЛА ОТВЕТА: STRONG

РИСК: Рецензент может настаивать, что Section 3 overstates результат. Ответ: мы синхронизируем формулировки (см. ниже).

---

### ПРОБЛЕМА: Section 3 overstates scope результата (Attacker 3, Проблема 8)

REBUTTAL RESPONSE:
"""
We thank the reviewer for noting the discrepancy between Section 3 and Appendix D. We have revised Section 3 (line 17) to explicitly state the replay model scope:

**Before:** "Appendix~D... proves that... the expected squared norm after $T$ batches is nondecreasing..."

**After:** "Appendix~D formalizes a coupling **mechanism** that, under the replay model (treating update magnitudes as fixed), proves that expected squared norm is nondecreasing in sampling probability. This isolates the sampling-frequency contribution guaranteed by the four conditions of Section~2."

This aligns with the explicit limitation stated in Appendix D (lines 48–51).
"""

ТАКТИКА: Concede-and-pivot
- Признать несоответствие, исправить формулировку

СИЛА ОТВЕТА: STRONG

РИСК: Минимальный. Это уточнение, не изменение результата.

---

### ПРОБЛЕМА: Модель счётчика "≥1 появление = один апдейт" (Attacker 2, Проблема 2)

REBUTTAL RESPONSE:
"""
We thank the reviewer for this observation about multiplicity within batches.

**Clarification:** The replay model counts **batches in which item $i$ appears**, not individual occurrences. When item $i$ appears $c_v > 1$ times in a batch, the update magnitude $\delta_k$ at that batch naturally incorporates the aggregated effect of all occurrences (since $\Delta q_v = -\eta \sum_{b: x_b = v} g_b$).

In other words: $N_T^{(p)}$ counts how many of $T$ batches contain item $i$, and each such batch contributes one $\delta_k$ to the sum. The $\delta_k$ itself depends on the number of occurrences and their gradients.

**Why this is correct:** For embedding layers, the squared update magnitude is:
$$\delta_k = \|\Delta q_v\|^2 = \eta^2 \left\|\sum_{b: x_b = v} g_b\right\|^2$$

This correctly aggregates contributions from multiple occurrences. The replay model does not assume "one occurrence per batch" — it treats $\delta_k$ as the (possibly aggregated) increment at the $k$-th update batch.
"""

ТАКТИКА: Clarify
- Объяснить, что $\delta_k$ уже включает агрегацию по вхождениям

СИЛА ОТВЕТА: STRONG

РИСК: Минимальный. Модель корректно определена.

---

### ПРОБЛЕМА: ε-стабилизация cosine ломает строгую ортогональность (Attacker 2, Проблема 4)

REBUTTAL RESPONSE:
"""
We thank the reviewer for raising this practical consideration.

**Scope clarification:** Our analysis assumes the mathematical definition $\cos(q,k) = \langle q, k \rangle / (\|q\| \cdot \|k\|)$. In production systems with numerical stabilization $\|q\|_\varepsilon = \sqrt{\|q\|^2 + \varepsilon}$:
- The gradient is no longer exactly orthogonal to $q$
- The deviation is $O(\varepsilon / \|q\|^2)$ for typical $\varepsilon \ll \|q\|^2$

**Our contribution:** We identify the **idealized mechanism** that explains popularity bias. Practical systems approximate this mechanism to the extent that $\varepsilon$ is small relative to embedding norms. This is analogous to how gradient descent theory assumes exact gradients while practice uses finite-precision arithmetic.

We have added a discussion in Section 5 (Conclusion): "The theoretical results assume exact cosine computation; numerical stabilization introduces small deviations from strict orthogonality, but the mechanism remains approximately valid for typical stabilization parameters."
"""

ТАКТИКА: Scope defense
- Статья описывает идеализированную модель; практика — приближение

СИЛА ОТВЕТА: MEDIUM

РИСК: Рецензент может считать это limitation слишком существенным. Ответ: эмпирические результаты (Table 2) валидируют механизм несмотря на практические отклонения.

---

### ПРОБЛЕМА: $\|q\| > 0$ не указано явно (Attacker 2, Проблема 5; Attacker 3, Проблема 10)

REBUTTAL RESPONSE:
"""
We thank the reviewer for noting this omission. We have added to Section 3 and Appendix D:

> "We assume $\|q_i^{(0)}\| > 0$ for all items. This is satisfied almost surely by standard random initialization (Xavier, He, or uniform from a bounded interval excluding zero). The dynamics preserve positivity: if $s_t > 0$ and $\delta_k > 0$, then $s_{t+1} = s_t + \delta_k > s_t > 0$."

Note that padding/special tokens with zero embeddings are typically excluded from the loss computation in practice.
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

РИСК: Нет.

---

### ПРОБЛЕМА: i.i.d. означает sampling with replacement и independence across time (Attacker 2, Проблема 6)

REBUTTAL RESPONSE:
"""
We thank the reviewer for requesting clarification. The i.i.d. assumption in Appendix D (Step 2) means:
1. Each batch slot is filled independently from the same distribution $p$
2. Batches at different steps are independent

This is the standard "with replacement" sampling model. We have added a clarifying sentence: "Batches are formed by i.i.d. sampling with replacement from distribution $p$ at each step."

**Scope limitation:** Sampling without replacement within epoch, hard-negative mining, or curriculum learning violate this assumption. Our results apply to systems using i.i.d. batch formation, which is common in large-scale training where the dataset is effectively infinite relative to batch size.
"""

ТАКТИКА: Clarify + Scope defense

СИЛА ОТВЕТА: STRONG

РИСК: Рецензент может note that practical systems often deviate. Ответ: this is a scope limitation explicitly stated.

---

### ПРОБЛЕМА: "Popularity" = $p_i$ sampling policy, не истинная частота (Attacker 2, Проблема 7)

REBUTTAL RESPONSE:
"""
We thank the reviewer for this clarification request. The theorem concerns the **sampling probability** $p_i$ used during training, not necessarily the "raw" popularity in user logs.

We have added to Section 3: "The result applies to the sampling distribution $p$ used during training. If popularity-corrected sampling is employed (e.g., downsampling head items), the norm correlates with effective sampling probability, not raw log frequency."

This is a feature, not a bug: practitioners can use this understanding to predict how different sampling strategies affect norm distributions.
"""

ТАКТИКА: Clarify

СИЛА ОТВЕТА: STRONG

РИСК: Нет.

---

### ПРОБЛЕМА: Перегрузка символа $c$ (count vs cosine)

REBUTTAL RESPONSE:
"""
We have revised the notation:
- $n_v$ — count of item $v$ in the batch (previously $c_i$ in Section 2.4)
- $\rho_i(q) = \cos(q, k_i)$ — cosine similarity (previously $c_i(q)$ in Appendix C)

This eliminates the overloading that caused confusion.
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

---

### ПРОБЛЕМА: "Claim" остаётся неформальным

REBUTTAL RESPONSE:
"""
We have reformulated the Claim as a formal Lemma:

**Lemma (Norm–Growth Inverse Relation).** Let $L(q) = F(\cos(q, k_1), \ldots, \cos(q, k_m))$ where $F$ is differentiable and $k_i \neq 0$. For $\|q\| > 0$:
$$\|\nabla_q L(q)\| = \frac{\|Pu\|}{\|q\|}$$
where $P = I - \hat{q}\hat{q}^\top$ and $u = \sum_i (\partial F/\partial \rho_i) \hat{k}_i$. Since $\|Pu\|$ is independent of $\|q\|$, the gradient norm decreases as $\|q\|$ increases.
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

---

### ПРОБЛЕМА: Boxed equality после "linearize"

REBUTTAL RESPONSE:
"""
We have revised Section 2.1 to use $\approx$:
$$\boxed{\; \Delta q_i \approx J_i \Delta\theta = -\eta \sum_j J_i J_j^\top g_j \;}$$
with clarification: "(Exact equality for parameter-linear encoders; see Section 2.2.)"
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

---

### ПРОБЛЕМА: "Replay model" не определён формально (Attacker 3, Проблема 7)

REBUTTAL RESPONSE:
"""
We have added a formal definition in Appendix D:

**Definition (Replay model).** Given a realization of the training process, let $\delta_k := \|\Delta q_i\|^2$ be the squared displacement at the $k$-th update of item $i$. The replay model treats $\{\delta_k\}_{k \geq 1}$ as a fixed (non-random) sequence and studies how the final norm $\|q_i^{(T)}\|^2 = \|q_i^{(0)}\|^2 + \sum_{k=1}^{N_T} \delta_k$ depends on the update count $N_T^{(p_i)}$ as the sampling probability $p_i$ varies.

This isolates the sampling-frequency contribution. The full SGD dynamics, where $\{\delta_k\}$ depends on the trajectory, requires additional analysis beyond the four conditions.
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

---

## ЧАСТЬ 3: ИТОГОВАЯ СВОДКА

| Проблема | Тактика | Сила | Действие |
|----------|---------|------|----------|
| Формула обновления | — | — | Исправить в статье |
| Индексация | — | — | Исправить в статье |
| Section 3 ↔ Appendix D scope | Concede-and-pivot | STRONG | Синхронизировать |
| Replay model vs full SGD | Redirect + Clarify | STRONG | Показать явное ограничение |
| Модель счётчика (дубликаты) | Clarify | STRONG | Объяснить агрегацию |
| ε-стабилизация | Scope defense | MEDIUM | Добавить discussion |
| $\|q\| > 0$ | Concede-and-pivot | STRONG | Добавить условие |
| i.i.d. уточнение | Clarify + Scope | STRONG | Уточнить |
| "popularity" терминология | Clarify | STRONG | Добавить оговорку |
| Перегрузка $c$ | Concede-and-pivot | STRONG | Переименовать |
| Claim → Lemma | Concede-and-pivot | STRONG | Переформулировать |
| Boxed equality | Concede-and-pivot | STRONG | Использовать ≈ |
| Replay model definition | Concede-and-pivot | STRONG | Добавить Definition |

---

## ОБЩАЯ СТРАТЕГИЯ REBUTTAL

**КЛЮЧЕВОЕ ДОСТИЖЕНИЕ:** Attacker 1 дал **WEAK ACCEPT** — это означает, что **coupling-аргумент теперь корректен**. Основная логика proof-heavy части больше не содержит REJECT-level проблем.

**Стратегия:**

1. **Признать и исправить** нотационные проблемы (формула обновления, индексация)

2. **Подчеркнуть честность** replay model — авторы ЯВНО ограничили scope в Appendix D (строки 48-51)

3. **Синхронизировать** формулировки Section 3 и Appendix D

4. **Защитить scope limitations** (ε-стабилизация, i.i.d., etc.) как стандартные для теоретических работ

5. **Подчеркнуть эмпирическую валидацию** — Table 2 показывает correlation 0.66, 0.56 в реальных системах

**Ключевой аргумент для AC/PC:**

> "The coupling argument is now formally correct within the replay model framework, as acknowledged by the reviewers. The remaining issues are notational (indexing, symbol overloading) and scope-related (idealized cosine, i.i.d. assumption), which are standard limitations for theoretical analyses. The empirical results (Section 4) validate the mechanism in practical settings where these idealizations are only approximately satisfied."

---

**Подпись:** DEFENDER 2  
**Вердикт:** REBUTTAL ГОТОВ. Coupling корректен (WEAK ACCEPT от Attacker 1). Две проблемы требуют исправления в статье (формула, индексация); остальные защитимы как scope limitations или нотационные уточнения.

</DEFENDER_2>

