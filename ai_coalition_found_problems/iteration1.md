<ATTACKER_1>

# ATTACKER 1: Логические дыры в доказательствах

**Rejection rate: 80%. Репутация: нахожу фатальные логические дыры, которые другие пропускают.**

---

## ПРОБЛЕМА 1: Индукционный шаг в coupling-аргументе использует разные функции для двух прогонов

### ЛОКАЦИЯ: 
Appendix D (appendix_coupling_popularity.tex), пункт 4, строки 66-76; Appendix F (appendix_note_on_batch_difference.tex)

### SEVERITY: REJECT

### СУТЬ:
Coupling-аргумент утверждает "almost sure pathwise dominance" (Eq. 52): $s^{(t)}_{p''_i} \geq s^{(t)}_{p'_i}$ для всех $t$. Индукционный шаг использует монотонность функции $\Phi(s) = s + c/s$. Однако в двух coupled runs значение $c$ РАЗЛИЧАЕТСЯ ($c' \neq c''$), потому что батчи отличаются в слотах где $p'_i < U < p''_i$. Следовательно, индукция применяет ДВЕ РАЗНЫЕ функции $\Phi'(s) = s + c'/s$ и $\Phi''(s) = s + c''/s$, а не одну монотонную.

### ПОЧЕМУ ЭТО ФАТАЛЬНО:
Рецензент ICML легко построит контрпример, разрушающий индукцию. Центральный claim статьи о popularity bias (теоретическое обоснование) опирается на этот coupling-аргумент. Без него раздел 3 теряет formal proof и становится лишь эмпирическим наблюдением.

### КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ:
Пусть $s' = 10$, $s'' = 11$ (порядок: $s' < s''$).
Пусть $c' = 100$, $c'' = 1$ (разные $c$ в двух прогонах — батчи отличаются).

Тогда:
- $s'_{new} = 10 + 100/10 = 20$
- $s''_{new} = 11 + 1/11 \approx 11.09$

**Порядок перевернулся**: $s'_{new} = 20 > s''_{new} \approx 11.09$.

Индукционный шаг НАРУШЕН. "Almost sure pathwise dominance" НЕ ВЫПОЛНЯЕТСЯ.

---

## ПРОБЛЕМА 2: "Self-healing через AM-GM" не спасает coupling-аргумент

### ЛОКАЦИЯ:
Appendix G (appendix_note_on_c_variability.tex), строки 33-39

### SEVERITY: REJECT

### СУТЬ:
Авторы пытаются "залатать" дыру аргументом: "После любого шага $s_{new} \geq 2\sqrt{c}$ по AM-GM, поэтому система self-heals." Но AM-GM применяется к ОДНОМУ прогону с ОДНИМ $c$. В coupling сравниваются ДВА прогона с РАЗНЫМИ $c' \neq c''$. AM-GM гарантирует $s'_{new} \geq 2\sqrt{c'}$, но это НЕ ГАРАНТИРУЕТ $s'_{new} \leq s''_{new}$.

### ПОЧЕМУ ЭТО ФАТАЛЬНО:
Авторы представляют AM-GM как "математическую гарантию" self-healing. Рецензент укажет, что это подмена: AM-GM даёт bound для одного прогона, а нужен ORDER PRESERVATION между двумя прогонами. Это разные утверждения.

### КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ:
После контрпримера из ПРОБЛЕМЫ 1:
- $s'_{new} = 20 \geq 2\sqrt{100} = 20$ ✓ (AM-GM выполнен для прогона с $c'$)
- $s''_{new} \approx 11.09 \geq 2\sqrt{1} = 2$ ✓ (AM-GM выполнен для прогона с $c''$)

Оба прогона удовлетворяют AM-GM **независимо друг от друга**. Но порядок $s' \leq s''$ УЖЕ НАРУШЕН. AM-GM не восстанавливает порядок — он про другое.

Чтобы утверждать self-healing МЕЖДУ прогонами, нужно было бы показать, что на следующем шаге порядок восстановится. Но для этого нужен bound на $|c'_{t+1} - c''_{t+1}|$, которого нет.

---

## ПРОБЛЕМА 3: Эвристики выдаются за доказательство

### ЛОКАЦИЯ:
- Appendix F (appendix_note_on_batch_difference.tex), строки 4-6: "low-probability event"
- Appendix G (appendix_note_on_c_variability.tex), строки 23-31: "convergent training process", "statistically suppressed"

### SEVERITY: WEAK_REJECT

### СУТЬ:
Авторы используют фразы "low-probability event", "convergent training process", "statistically suppressed under random batch formation" без формализации. Это эвристические рассуждения, а не математическое доказательство.

### ПОЧЕМУ ЭТО ФАТАЛЬНО:
Для ICML теоретической статьи недостаточно сказать "это редко происходит". Нужно:
1. Формально определить распределение $c_t$
2. Оценить $\mathbb{P}(\text{reversal на шаге } t)$
3. Применить union bound для $T$ шагов
4. Показать, что суммарная вероятность нарушения мала

Ничего из этого не сделано. "Low-probability" — это не доказательство.

### КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ:
Пусть на каждом шаге $\mathbb{P}(\text{reversal}) = \epsilon > 0$. За $T$ шагов:
$$\mathbb{P}(\text{хотя бы один reversal за } T \text{ шагов}) \geq 1 - (1-\epsilon)^T \to 1 \text{ при } T \to \infty$$

Без явного bound на $\epsilon$ (или доказательства $\epsilon = 0$) утверждение "almost sure pathwise dominance" ЛОЖНО.

---

## ПРОБЛЕМА 4: Imprecision в выводе коллинеарности для embedding layer

### ЛОКАЦИЯ:
Section 2.4 (collinearity.tex), строки 28-33, уравнение (10)

### SEVERITY: MINOR

### СУТЬ:
Авторы пишут: $\Delta q_i = -\eta c_i g_i$, где $c_i$ — число вхождений $x_i$ в батч. Это неверно при $c_i > 1$: разные вхождения одного item имеют РАЗНЫЕ градиенты $g_j$ (зависят от paired item на другой башне). Правильно: $\Delta q_i = -\eta \sum_{j: x_j = x_i} g_j$.

### ПОЧЕМУ ЭТО НЕ ФАТАЛЬНО:
Ортогональность сохраняется: если $g_j \perp q_i$ для всех $j$, то $\sum_j g_j \perp q_i$. Результат Proposition 2.6 верен, но вывод imprecise.

### ИСПРАВЛЕНИЕ:
Заменить Eq. (10) на $\Delta q_i = -\eta \sum_{j: x_j = x_i} g_j$ и добавить: "Since each $g_j \perp q_i$, their sum is also orthogonal to $q_i$."

---

## ПРОБЛЕМА 5: Overloaded нотация 'c' создаёт путаницу

### ЛОКАЦИЯ:
- Section 2.4 (collinearity.tex), строка 29: $c_i$ = count в батче
- Appendix C (appendix_cosine_gradient_magnitude.tex), строка 41: $c_i(q)$ = cosine similarity
- Appendix D (appendix_coupling_popularity.tex), строка 38: $c$ = squared gradient magnitude factor

### SEVERITY: MINOR

### СУТЬ:
Три разных значения для одной буквы затрудняют чтение proof-heavy appendices. При чтении Appendix D и G непонятно, какое $c$ имеется в виду.

### ИСПРАВЛЕНИЕ:
Использовать разные символы: $n_i$ для counts, $\gamma$ для gradient magnitude factor.

---

## ИТОГОВЫЙ СТАТУС

**НЕ ЧИСТО.**

Обнаружены проблемы уровня REJECT:
1. Индукционный шаг в coupling-аргументе математически некорректен
2. AM-GM self-healing не решает проблему order preservation между прогонами
3. Эвристические рассуждения выдаются за формальное доказательство

**Центральный claim статьи** — "expected embedding norm is nondecreasing in sampling probability" с formal proof — **НЕ ДОКАЗАН СТРОГО**. 

Доказан только случай ФИКСИРОВАННОГО $c$ (или $c' = c''$). Для разных $c$ в coupling (реальный случай) — только эвристики.

---

## РЕКОМЕНДАЦИЯ

Для acceptance на ICML необходимо одно из:

**Вариант A: Ослабить claim до "in expectation" без pathwise dominance**
- Убрать "almost sure pathwise dominance"
- Доказать напрямую: $\mathbb{E}[s^{(T)}]_{p''} \geq \mathbb{E}[s^{(T)}]_{p'}$
- Это проще и не требует контроля над $c' - c''$

**Вариант B: Добавить явное условие на boundedness $c$**
- Добавить (A5): $c_t \leq C$ для всех $t$
- Показать, что для InfoNCE это выполняется (softmax bounded)

**Вариант C: Формализовать probabilistic argument**
- Определить распределение $c_t$
- Доказать concentration: $|c' - c''| \leq \delta$ w.h.p.
- Применить union bound по $T$ шагам

---

**Подпись:** ATTACKER 1  
**Вердикт:** REJECT (логические дыры в центральном доказательстве)

</ATTACKER_1>

<ATTACKER_2>

# ATTACKER 2: Неявные допущения и скрытые условия

**Специализация:** Optimization theory, Google DeepMind  
**Репутация:** Разрушаю красивые теоремы вопросом "А что если это условие не выполняется?"

---

## ПРОБЛЕМА 1: Неявное предположение $\|q\| > 0$ и отсутствие анализа инициализации

### ЛОКАЦИЯ:
- Appendix C (appendix_cosine_gradient_magnitude.tex), формула (84):
  $$\|\nabla_q L(q)\| = \frac{\sqrt{\|u\|^2 - (\hat{q}^\top u)^2}}{\|q\|}$$
- Appendix D (appendix_coupling_popularity.tex), формула $\Delta(s) = c/s$

### SEVERITY: WEAK_REJECT

### НЕЯВНОЕ ДОПУЩЕНИЕ:
Формулы предполагают $\|q\| > 0$ (или $s = \|q\|^2 > 0$). Авторы нигде не указывают это условие явно и не анализируют, как обеспечивается $\|q\|^{(0)} \neq 0$ при инициализации.

### ГДЕ ИСПОЛЬЗУЕТСЯ:
1. Формула нормы градиента делит на $\|q\|$
2. Функция $\Phi(s) = s + c/s$ не определена при $s = 0$
3. AM-GM применяется к $s > 0$

### КОНТРПРИМЕР:
Стандартная инициализация embedding layer может включать нулевые строки (например, для padding token с индексом 0). При $q^{(0)} = 0$:
- $\nabla_q L(q)$ — undefined (деление на ноль)
- $s^{(0)} = 0$ ⟹ $\Phi(s)$ undefined

Первое же обновление ломает всю математику.

### ТРЕБУЕМОЕ ИСПРАВЛЕНИЕ:
Добавить явное условие: **(A0)** $\|q_i^{(0)}\| > 0$ для всех item'ов $i$.

---

## ПРОБЛЕМА 2: Отсутствие условия на распределение batch formation

### ЛОКАЦИЯ:
- Appendix D (appendix_coupling_popularity.tex), пункт 1 "Two runs on the same randomness"
- Appendix E (appendix_note_on_distributions.tex), вся секция

### SEVERITY: WEAK_REJECT

### НЕЯВНОЕ ДОПУЩЕНИЕ:
Coupling-аргумент предполагает, что batches формируются i.i.d. из фиксированного распределения $p$ на каждом шаге. Это НИГДЕ не указано как условие.

### ГДЕ ИСПОЛЬЗУЕТСЯ:
1. Uniform random variable $U$ в coupling construction
2. Утверждение "the number of appearances of $i$ is never smaller" (Appendix D, строка 24)
3. Вся индукция по шагам предполагает одинаковое распределение на каждом $t$

### КОНТРПРИМЕРЫ:

**Контрпример A: Curriculum learning**
Если $p_i^{(t)}$ меняется во времени (начинаем с простых примеров, постепенно добавляем сложные), coupling-аргумент ломается: на разных $t$ используются разные распределения.

**Контрпример B: Temporal dependencies**
Если выбор items в batch $t$ зависит от batch $t-1$ (например, отложенные негативы, streaming data), условие i.i.d. нарушается.

**Контрпример C: Sampling without replacement within epoch**
Если items выбираются без повторений внутри эпохи, вероятность $p_i^{(t)}$ зависит от того, был ли $i$ уже выбран ранее в эпохе.

### ТРЕБУЕМОЕ ИСПРАВЛЕНИЕ:
Добавить условие: **(A5)** Batch formation is i.i.d. from a fixed distribution $p$ at each step $t$.

---

## ПРОБЛЕМА 3: Неявное предположение об ограниченности $\partial F / \partial c_i$

### ЛОКАЦИЯ:
- Appendix C (appendix_cosine_gradient_magnitude.tex), формулы (62)-(64):
  $$u = \sum_{i=1}^{m} \frac{\partial F}{\partial c_i} \hat{k}_i$$
- Appendix G (appendix_note_on_c_variability.tex), строки 29-31: "magnitude of $\tfrac{\partial F}{\partial cos}$, whose stability follows from the argument above"

### SEVERITY: MINOR

### НЕЯВНОЕ ДОПУЩЕНИЕ:
Авторы утверждают, что $\|u\|$ ограничена, ссылаясь на "stability" производных $\partial F / \partial c_i$. Но для произвольной "cosine-based loss" $F$ это не гарантировано.

### ГДЕ ИСПОЛЬЗУЕТСЯ:
1. Аргумент о том, что $c = \eta^2 \|Pu\|^2$ не растёт "слишком быстро"
2. Утверждение "sum of contributions is bounded by... magnitude of $\partial F / \partial cos$"

### КОНТРПРИМЕР:
Пусть $F(c_1, \ldots, c_m) = \exp\bigl(\lambda \cdot \sum_i c_i\bigr)$ — это допустимая "cosine-based loss". Тогда:
$$\frac{\partial F}{\partial c_i} = \lambda \cdot F$$
При росте косинусов, $F$ и производные растут экспоненциально. Утверждение о "stability" ЛОЖНО для такой loss.

### ПОЧЕМУ НЕ ФАТАЛЬНО:
InfoNCE использует softmax, производные которого ограничены $[0, 1/\tau]$. Но авторы заявляют результат для "any cosine-based loss", не для конкретной.

### ТРЕБУЕМОЕ ИСПРАВЛЕНИЕ:
Либо добавить условие: **(A6)** $|\partial F / \partial c_i| \leq M$ for some constant $M$.
Либо ограничить claim до "InfoNCE and similar losses with bounded derivatives".

---

## ПРОБЛЕМА 4: Молчаливое использование $\|u\|^2 \geq (\hat{q}^\top u)^2$

### ЛОКАЦИЯ:
- Appendix C (appendix_cosine_gradient_magnitude.tex), формула (76) и далее

### SEVERITY: MINOR

### НЕЯВНОЕ ДОПУЩЕНИЕ:
Формула $\|Pu\|^2 = \|u\|^2 - (\hat{q}^\top u)^2$ используется без проверки того, что подкоренное выражение $\geq 0$.

### ГДЕ ИСПОЛЬЗУЕТСЯ:
Финальная формула (84): $\|\nabla_q L(q)\| = \frac{\sqrt{\|u\|^2 - (\hat{q}^\top u)^2}}{\|q\|}$

### ПОЧЕМУ ЭТО ВЕРНО (но не сказано):
Из Cauchy-Schwarz: $|\hat{q}^\top u| \leq \|\hat{q}\| \cdot \|u\| = \|u\|$, поэтому $(\hat{q}^\top u)^2 \leq \|u\|^2$.

### ТРЕБУЕМОЕ ИСПРАВЛЕНИЕ:
Добавить одну строку: "By Cauchy-Schwarz, $(\hat{q}^\top u)^2 \leq \|u\|^2$, so the square root is real."

---

## ПРОБЛЕМА 5: Граничный случай $d = 1$ (одномерные эмбеддинги)

### ЛОКАЦИЯ:
- Section 2.5 (cosine_gradient_orthogonality.tex): "$q_i \perp \Delta q_i$"
- Section 3, Pythagorean theorem application

### SEVERITY: MINOR

### НЕЯВНОЕ ДОПУЩЕНИЕ:
Вся геометрическая интерпретация ("orthogonal movement", "tangent to hypersphere") предполагает $d \geq 2$.

### КОНТРПРИМЕР:
При $d = 1$: 
- $q \in \mathbb{R}^1$ — скаляр
- $\nabla_q \cos(q, k) = \frac{k - \frac{qk}{q^2}q}{|q||k|} = \frac{k - \text{sign}(qk) \cdot k}{|q||k|} = 0$ если $qk > 0$, иначе $\frac{2k}{|q||k|}$

При $d = 1$ и $qk > 0$: градиент косинуса **равен нулю**! Ортогональность тривиальна, но это потому что градиент = 0, а не потому что он ортогонален.

### ПОЧЕМУ НЕ ФАТАЛЬНО:
На практике $d \gg 1$ (типично 64-768). Но формально результат не покрывает $d = 1$.

### ТРЕБУЕМОЕ ИСПРАВЛЕНИЕ:
Добавить: "We assume $d \geq 2$ throughout; the case $d = 1$ is degenerate."

---

## ПРОБЛЕМА 6: Условие на learning rate в coupling не формализовано

### ЛОКАЦИЯ:
- Section 3 (norm_growth_vs_popularity.tex), строка 20: "an additional (fifth) factor is required"
- Appendix D (appendix_coupling_popularity.tex): нет условий на $\eta$

### SEVERITY: MINOR

### НЕЯВНОЕ ДОПУЩЕНИЕ:
Coupling-аргумент использует $c = \eta^2 \|Pu\|^2$. Если $\eta \to 0$, то $c \to 0$, и норма эмбеддинга практически не растёт (независимо от popularity). Авторы упоминают это в секции экспериментов (condition 5), но **не включают в теоретический claim**.

### ГДЕ ИСПОЛЬЗУЕТСЯ:
Вся индукция в Appendix D: $s^{(t+1)} = s^{(t)} + c/s^{(t)}$ требует $c > 0$ (или $\eta > 0$).

### ПОЧЕМУ ЭТО ВАЖНО:
Теоретический результат (Section 3, Appendix D) заявляет монотонность нормы в popularity БЕЗ условия на learning rate. Но при $\eta \to 0$ монотонность формально сохраняется (т.к. $c \geq 0$), однако ПРАКТИЧЕСКИЙ эффект popularity bias исчезает.

### ТРЕБУЕМОЕ ИСПРАВЛЕНИЕ:
Чётко разделить:
1. Теоретический результат: "$\mathbb{E}[\|q\|]$ nondecreasing in $p_i$" — верно для любого $\eta > 0$
2. Практическая значимость: "observable bias requires sufficiently large $\eta$"

---

## ПРОБЛЕМА 7: Неявное условие на режим обучения (convergent training)

### ЛОКАЦИЯ:
- Appendix G (appendix_note_on_c_variability.tex), строки 23-29: "In a convergent training process..."

### SEVERITY: WEAK_REJECT

### НЕЯВНОЕ ДОПУЩЕНИЕ:
Аргумент о том, что $c$ не растёт экспоненциально, опирается на "convergent training process". Но:
1. Сходимость не определена формально
2. Не указано, какие условия гарантируют сходимость
3. Результат Section 3 заявлен без условия на сходимость

### ГДЕ ИСПОЛЬЗУЕТСЯ:
Обоснование self-healing в coupling: "persistent sharp growth of $u$ would signal a diverging training process"

### КОНТРПРИМЕР:
На ранних этапах обучения (до сходимости) $u$ может расти значительно. Coupling-аргумент (в том виде, как он изложен) не работает для первых $T_0$ шагов до "стабилизации".

### ПОЧЕМУ ЭТО СЕРЬЁЗНО:
Popularity bias, если он возникает, часто формируется именно на ранних этапах обучения. Если аргумент не работает для начальной фазы — это существенное ограничение.

### ТРЕБУЕМОЕ ИСПРАВЛЕНИЕ:
Добавить условие: **(A7)** Training is in a stable regime where $\|u_t\| \leq U_{max}$ for all $t$.
Либо ослабить claim до asymptotic behavior.

---

## ИТОГОВЫЙ СТАТУС

**НЕ ЧИСТО. Критических скрытых допущений не уровня REJECT, но три проблемы уровня WEAK_REJECT:**

| № | Проблема | Severity | Тип |
|---|----------|----------|-----|
| 1 | $\|q\| > 0$ не указано | WEAK_REJECT | Граничный случай |
| 2 | i.i.d. batch formation не указано | WEAK_REJECT | Скрытое условие на данные |
| 7 | "Convergent training" используется без определения | WEAK_REJECT | Скрытое условие на оптимизацию |
| 3 | Bounded $\partial F/\partial c_i$ предполагается | MINOR | Скрытое условие на loss |
| 4 | Cauchy-Schwarz не упомянут | MINOR | Молчаливое использование |
| 5 | $d \geq 2$ не указано | MINOR | Граничный случай |
| 6 | Learning rate в теории vs практике | MINOR | Несоответствие claim'а |

---

## РЕКОМЕНДАЦИИ

### Минимальные исправления для acceptance:

1. **Явно указать условия инициализации:**
   > "We assume $\|q_i^{(0)}\| > 0$ for all items (standard random initialization satisfies this almost surely)."

2. **Явно указать условие на batch formation:**
   > "Batches are formed by i.i.d. sampling from a fixed distribution $p$."

3. **Уточнить scope для "convergent training":**
   > "The coupling argument holds under a bounded gradient regime, $\|u_t\| \leq U_{max}$, which is typical for convergent training with InfoNCE loss."

4. **Добавить footnote про $d = 1$:**
   > "The analysis assumes $d \geq 2$; the one-dimensional case is degenerate."

---

**Подпись:** ATTACKER 2  
**Специализация:** Скрытые допущения и граничные случаи  
**Вердикт:** WEAK_REJECT (множественные неявные условия требуют явного указания)

</ATTACKER_2>

<ATTACKER_3>

# ATTACKER 3: Формальная строгость и consistency

### ПРОБЛЕМА 1: Смешение ролей индексов \(i\) (item) и \(i\) (пример батча)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26/sections/one_formula.tex`, `.../sections/collinearity.tex`, `.../sections/norm_growth_vs_popularity.tex`, `.../sections/appendix_encoders.tex`
SEVERITY: WEAK_REJECT
ПРОБЛЕМА: В тексте одновременно используются
- \(g_j\), \(J_j\) как «для \(j\)-го примера в батче» (`one_formula.tex`),
- \(q_i\), \(\Delta q_i\) как «эмбеддинг item’а \(i\)» (`norm_growth_vs_popularity.tex`, coupling),
- и при этом в приложениях (`appendix_encoders.tex`) \(x_i=i\) объявляется «индекс примера \(i\)».
Это создаёт формальную неоднозначность: когда \(i\) — это item-id (элемент словаря), а когда — индекс training-example в батче.
КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ: «Notation is inconsistent: the same index \(i\) alternates between an item identity and a batch example index, making statements like \(\Delta q_i\) and \(s^{(t)}=\|q_i^{(t)}\|^2\) ill-defined.»
ИСПРАВЛЕНИЕ: Жёстко развести индексы: например, \(b\in\{1,\dots,B\}\) — слот/пример батча, \(v\in\{1,\dots,N\}\) — item-id, и везде писать \(g_b, J_b\) и \(q_v, \Delta q_v\). В `appendix_encoders.tex` заменить формулировку «\(x_i\) — index of example \(i\)» на «\(x_b\) — item-id in batch slot \(b\)».

### ПРОБЛЕМА 2: Формула \(\Delta q_i=-\eta\,c_i g_i\) не следует из заявленных определений (дубликаты item’а в батче)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26/sections/collinearity.tex`, абзац “Single embedding layer”, уравнения \((\ref{eq:JJ-embed})\) и далее
SEVERITY: WEAK_REJECT
ПРОБЛЕМА: При \(c_i>1\) корректная подстановка даёт \(\Delta q_{v}=-\eta \sum_{b:\,x_b=v} g_b\). В тексте же появляется \(-\eta\,c_i g_i\), где \(g_i\) формально определён как градиент «для \(i\)-го примера», а не для item’а \(v\). Это не просто «нестрогость» — это буквальная подмена объекта.
КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ: «Eq. (10) is not derived: the paper treats \(g_i\) as a per-item gradient while it was defined per batch example; the correct update is a sum over occurrences.»
ИСПРАВЛЕНИЕ: Переписать вывод через суммирование по слотам батча. Если хотите сохранить скалярный множитель \(c_v\), нужно явно ввести \( \bar g_v := \frac{1}{c_v}\sum_{b:\,x_b=v} g_b\) и тогда \(\Delta q_v=-\eta\,c_v\,\bar g_v\).

### ПРОБЛЕМА 3: Ключевые утверждения оформлены как “Claim” без формальных кванторов/условий
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26/sections/norm_growth_vs_popularity.tex`, строки с “\textbf{Claim.} …”
SEVERITY: MINOR
ПРОБЛЕМА: Утверждение “The larger the embedding norm, the slower it grows under a cosine-based loss” подано как неформальная вставка без условий (например, \(\|q\|>0\), nonzero \(k\), какой именно процесс \(q^{(t)}\) рассматривается, фиксированы ли остальные аргументы \(F\)). В proof-heavy paper это выглядит как «разговорный» тезис, хотя ниже он используется как лемма для coupling-части.
КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ: «Important steps are stated informally; it is unclear under which conditions the ‘Claim’ holds and what is being quantified over.»
ИСПРАВЛЕНИЕ: Оформить как Lemma/Proposition с явными предпосылками (как минимум \(\|q\|>0\), \(k_i\neq 0\), differentiability of \(F\)), и явно уточнить, что речь про зависимость \(\|\nabla_q L(q)\|\propto 1/\|q\|\) при фиксированных косинусах.

### ПРОБЛЕМА 4: В главной формуле динамики не отмечено, что это линейная аппроксимация (а не равенство)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26/sections/one_formula.tex`, boxed \(\Delta q_i = J_i \Delta\theta\); плюс `.../sections/interim_focus.tex`
SEVERITY: MINOR
ПРОБЛЕМА: В `one_formula.tex` формула выводится с «полным равенством» после “we linearize … and obtain”, хотя для general encoders это \(\Delta q_i = J_i\Delta\theta + O(\|\Delta\theta\|^2)\). Да, позже (`interim_focus.tex`) сказано, что для parameter-linear это точно, но локально читатель видит строгую «boxed equality» без оговорки.
КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ: «The core equation is presented as equality while it is a first-order approximation; the paper relies on later caveats, which undermines formal clarity.»
ИСПРАВЛЕНИЕ: Заменить знак равенства на \(\approx\) в `one_formula.tex` или добавить явную строку “first-order Taylor expansion, with equality for parameter-linear encoders”.

### ПРОБЛЕМА 5: Неформальное/размытое условие “non-shared parameter row” не эквивалентно реальным операторным условиям на \(J_iJ_j^\top\)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26/sections/collinearity.tex` (условия (i)–(ii)), `.../sections/orthogonal_motion_summary.tex` (список из 4 условий)
SEVERITY: WEAK_REJECT
ПРОБЛЕМА: В `collinearity.tex` корректное (и проверяемое) условие — это операторные равенства для \(J_iJ_j^\top\). В summary это заменяется разговорным “each distinct input has a dedicated, non-shared parameter row”. Для линейного слоя с one-hot/ортогональными входами ортогональность достигается без “dedicated row” в буквальном смысле, и наоборот, “non-shared row” сам по себе не гарантирует изотропию \(J_iJ_i^\top=\alpha_i I_d\).
КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ: «The stated ‘four conditions’ are not the actual sufficient conditions; the paper switches from precise Jacobian-product conditions to informal architectural language.»
ИСПРАВЛЕНИЕ: В summary-списке заменить пункт (A3) на формальное условие в терминах \(J_iJ_j^\top\) (или дать эквивалентность “architecture ⇒ (i)–(ii)” только для перечисленных архитектур), и отдельно явно указать требование “distinct inputs orthogonal” для линейного слоя.

### ПРОБЛЕМА 6: “Vary only \(p_i\)” не формализовано как семейство распределений (нормировка заставляет менять остальные вероятности)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26/sections/appendix_coupling_popularity.tex`, пункт 1; `.../sections/appendix_note_on_distributions.tex`
SEVERITY: WEAK_REJECT
ПРОБЛЕМА: Фраза “differing only in the sampling probability of item \(i\): \(p_i' < p_i''\)” формально невозможна для распределений на конечном множестве без уточнения, как меняются \(p_k, k\neq i\). В `appendix_note_on_distributions.tex` вводится residual distribution \(r\) и масштаб \(\gamma\), но это не «привязано» в основной формулировке утверждения о монотонности по \(p_i\).
КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ: «Monotonicity ‘in \(p_i\)’ is ill-defined unless the path in the simplex is specified; the proof implicitly rescales other probabilities.»
ИСПРАВЛЕНИЕ: Явно определить семейство \(p(p_i)\) через фиксированный residual \(r\): \(p_k(p_i)=(1-p_i)r_k\) для \(k\neq i\). Тогда утверждение “nondecreasing in \(p_i\)” становится формальным.

### ПРОБЛЕМА 7: Перегрузка символа \(c\) (count / cosine / gradient-magnitude factor) ломает читаемость и провоцирует ошибки чтения
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26/sections/collinearity.tex` (\(c_i\)=count), `.../sections/appendix_cosine_gradient_magnitude.tex` (\(c_i(q)=\cos(\cdot)\)), `.../sections/appendix_note_on_c_variability.tex` (\(c=\eta^2\|Pu\|^2\))
SEVERITY: MINOR
ПРОБЛЕМА: Три разных объекта под одним “\(c\)” и “\(c_i\)” существенно увеличивают когнитивную нагрузку именно в proof-heavy части (Appendix C/D/G), и это уже привело к реальным misreads (см. обсуждение в iteration0 про \(c\)).
КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ: «Notation is overloaded and error-prone; \(c\) denotes three unrelated quantities across sections.»
ИСПРАВЛЕНИЕ: Переименовать: \(n_i\) для counts, \(\rho_i(q)\) для cosine similarities, \(\kappa\) (или \(C_t\)) для \(\eta^2\|Pu\|^2\).

### ПРОБЛЕМА 8: Несогласованная запись производных \(\partial F/\partial c_i\) vs \(\partial F/\partial \cos_i\)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26/sections/appendix_note_on_c_variability.tex`, строки с \(u=\sum \partial F/\partial c_i\,\hat k_i\) и далее с \(\partial F/\partial \cos_i\)
SEVERITY: MINOR
ПРОБЛЕМА: В Appendix C вводится \(c_i(q)=\cos(q,k_i)\) и затем \(\partial F/\partial c_i\). В `appendix_note_on_c_variability.tex` внезапно появляется \(\partial F/\partial \cos_i\) (без определения \(\cos_i\)), что формально является сменой обозначений в середине доказательной цепочки.
КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ: «Derivative notation is inconsistent (\(c_i\) vs \(\cos_i\)), which obscures the dependence of \(u\) and \(c\) on the batch.»
ИСПРАВЛЕНИЕ: Везде оставить один стиль: либо \(\partial F/\partial c_i\) при \(c_i=\cos(\cdot)\), либо явно определить \(\cos_i:=\cos(q,k_i)\) и использовать \(\partial F/\partial \cos_i\) последовательно.

### ИТОГОВЫЙ СТАТУС
СТАТУС: НЕ ЧИСТО. Есть несколько проблем формальной строгости уровня WEAK_REJECT (индексы/семейство распределений/формулировка условий), и несколько MINOR (перегрузка нотаций, локальные неясности).

</ATTACKER_3>

<AGGREGATOR SUMMARY>

# КОНСОЛИДИРОВАННЫЙ СПИСОК ПРОБЛЕМ

## КРИТИЧЕСКИЕ (любая из них = reject)
1. Coupling-доказательство монотонности по \(p_i\) некорректно из-за разного \(c\) в двух coupled runs (нарушается сохранение порядка)
   - Источник: Attacker 1 (Проблема 1), Attacker 1 (Проблема 2), Attacker 1 (Проблема 3)
   - Суть: Индукционный шаг требует монотонности одной и той же функции \(\Phi(s)=s+c/s\), но в coupled runs возникают \(c'\neq c''\), т.е. фактически применяются две разные \(\Phi',\Phi''\); есть явный контрпример, где порядок \(s'\le s''\) переворачивается после шага. Попытка «self-healing» через AM–GM не решает именно задачу сохранения порядка между двумя прогонами, а апелляции к “low-probability event / convergent training / statistically suppressed” остаются нефомализованными эвристиками.
   - Impact: Центральный теоретический claim про popularity dependence (Section 3 + Appendix “Popularity Dependence via Coupling”) теряет строгую основу; без корректного аргумента монотонность ожидаемой нормы по \(p_i\) не доказана в заявленном виде.

## СЕРЬЁЗНЫЕ (накопление = weak reject)
1. Несогласованность индексов (item-id vs индекс примера/слота в батче) делает ряд утверждений формально неоднозначными
   - Источник: Attacker 3 (Проблема 1), Attacker 3 (Проблема 2)
   - Суть: В тексте одновременно используются \(g_j,J_j\) как «для \(j\)-го примера батча» и \(q_i,\Delta q_i\) как «для item \(i\)», но местами \(i\) перегружен и как индекс примера. Из-за этого выводы вида \(\Delta q_i=-\eta c_i g_i\) при повторах item’а в батче требуют аккуратного суммирования по вхождениям (и/или введения \(\bar g\)).
   - Impact: Рецензент может указать на «ill-defined notation / derivation gap» в базовых секциях, что подрывает доверие к последующим выкладкам (включая coupling-часть).

2. В теории используются неявные условия (инициализация, i.i.d. batch formation, “convergent/stable regime”), которые не заявлены как предпосылки
   - Источник: Attacker 2 (Проблемы 1, 2, 7), Attacker 1 (Проблема 3)
   - Суть: Формулы и доказательства подразумевают \(\|q\|>0\) (иначе деление на \(\|q\|\) / \(s=0\) ломает выражения), i.i.d. батчи из фиксированного распределения, а также «стабильность»/ограниченность величин в духе \(\|u_t\|\) в рассуждениях о вариабельности \(c\). Эти условия фигурируют как текстовые оговорки, но не как формальные предпосылки теорем/лемм.
   - Impact: Без явных кванторов/условий получаются утверждения с “hidden assumptions”; для теоретической ICML-статьи это может тянуть на weak reject, даже если авторы интуитивно имеют в виду стандартный режим.

3. “Монотонность по \(p_i\)” требует формализации пути в симплексе распределений (нельзя «менять только \(p_i\)» без уточнения остальных вероятностей)
   - Источник: Attacker 3 (Проблема 6)
   - Суть: Формулировка “differing only in the sampling probability of item \(i\): \(p_i'<p_i''\)” неполна без явного описания, как пересчитываются \(p_k, k\neq i\) (нормировка). В тексте вводятся residual distribution/масштабирование, но это должно быть привязано к основной формулировке монотонности.
   - Impact: Неформальность подрывает строгость постановки основной теоремы и облегчает критику со стороны рецензента.

4. Список «условий/премис» в summary частично подменяет строгие операторные условия на более разговорные архитектурные формулировки
   - Источник: Attacker 3 (Проблема 5)
   - Суть: В доказательных секциях условия задаются через \(J_iJ_j^\top\), а в summary появляются формулировки вроде “dedicated, non-shared parameter row”, которые не эквивалентны строгим условиям без дополнительных оговорок (и могут быть поняты неверно).
   - Impact: Риск замечания “the sufficient conditions are misstated / not equivalent”, что снижает воспринимаемую корректность теории.

## МИНОРНЫЕ (желательно исправить)
1. Перегрузка символа \(c\) для разных сущностей (count / cosine / gradient-magnitude factor)
   - Источник: Attacker 1 (Проблема 5), Attacker 3 (Проблема 7)
   - Суть: Один и тот же символ используется для разных величин в разных секциях/аппендиксах.

2. Локальные нестрогости/оговорки по математике и формату
   - Источник: Attacker 2 (Проблемы 4, 5, 6), Attacker 3 (Проблемы 3, 4, 8)
   - Суть: Не проговорен Cauchy–Schwarz для неотрицательности подкоренного выражения; не оговорён вырожденный случай \(d=1\); смешение “Claim” без формальных кванторов; boxed-равенство после linearization без явной пометки “first-order approx” (кроме спец-случая); несогласованная запись \(\partial F/\partial c_i\) vs \(\partial F/\partial \cos_i\).

3. Уточнение про корректную форму обновления при дубликатах item’а в батче
   - Источник: Attacker 1 (Проблема 4), Attacker 3 (Проблема 2)
   - Суть: При \(c_i>1\) нужно писать сумму по вхождениям (или вводить средний градиент \(\bar g\)); иначе возникает подмена объекта (градиент “по примеру” vs “по item”).

## ОТКЛОНЁННЫЕ
(нет)

## СТАТУС ИТЕРАЦИИ
- Критических проблем: 1
- Серьёзных проблем: 4
- ВЕРДИКТ: ТРЕБУЕТ ДОРАБОТКИ (в текущем виде центральное coupling-доказательство не проходит; нужна переработка формальной части и явные условия/нотация)

</AGGREGATOR SUMMARY>

<DEFENDER_1>

### ПРОБЛЕМА: Coupling-доказательство монотонности по \(p_i\) некорректно из-за разного \(c\) в двух coupled runs (нарушается сохранение порядка)
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна
- Severity: REJECT
- Направление исправления: убрать/ослабить «almost sure pathwise dominance» и переписать теоретический claim так, чтобы он **не требовал** индукции вида \(s'\le s'' \Rightarrow s'+c'/s' \le s''+c''/s''\) при \(c'\neq c''\). Минимально безопасно: (i) заменить результат на **conditional** (ввести явное предположение, которое связывает \(c'\) и \(c''\) между прогонами), или (ii) честно понизить формальность Section 3: «механизм» строго (ортогональность + \(\Delta(s)=c/s\)), а «монотонность по популярности» — эмпирически подтверждаемая гипотеза/наблюдение.
- Почему это действительно дыра (по тексту статьи): в Appendix “Popularity Dependence via Coupling” монотонность шага обоснована для одной функции \(\Phi(s)=s+c/s\) и далее используется в пункте 4 как будто \(c\) общий, см. формулировку требования “the mapping \(\Phi(s)=s+\Delta(s)\) is nondecreasing” и затем “if \(i\) appears in both runs, the nondecreasing \(\Phi(s)\) preserves the order” при том, что в “Note on batch difference” прямо признаётся, что батчи и значит \(c\) могут отличаться между прогонами (“it may happen that \(c''<c'\) …”), после чего следует неформальная отсылка к “low-probability event”, что не закрывает индукцию.

### ПРОБЛЕМА: Несогласованность индексов (item-id vs индекс примера/слота в батче) делает ряд утверждений формально неоднозначными
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна
- Severity: WEAK_REJECT
- Направление исправления: жёстко развести индексы по смыслу во всей статье и аппендиксах: например, \(b\) — слот/пример в батче (где сейчас \(g_j,J_j\) из `one_formula.tex`), \(v\) — item-id (где сейчас \(q_i,s^{(t)}=\|q_i^{(t)}\|^2\) в Section 3). Особенно конфликтно, что в `appendix_encoders.tex` написано “Input: \(x_i=i\) … (\(x_i\) — index of example \(i\))”, что провоцирует ровно тот misread, который ломает выводы в Section 2.4/Appendix D.

### ПРОБЛЕМА: Неверная/нестрогая запись обновления для embedding layer при повторах одного item в батче (Eq. \(\Delta q_i=-\eta c_i g_i\))
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна (это не просто “стилистика”: в текущей нотации \(g_i\) определён как градиент **для \(i\)-го примера батча**, а \(c_i\) — как число вхождений **одного item**; это разные уровни индексации)
- Severity: WEAK_REJECT (потому что подрывает доверие к “proof-heavy” части, хотя конечная ортогональность может сохраниться)
- Направление исправления: переписать вывод как сумму по вхождениям: \(\Delta q_v=-\eta\sum_{b:\,x_b=v} g_b\). Если хочется оставить множитель “count”, ввести \(\bar g_v := \frac1{c_v}\sum_{b:\,x_b=v}g_b\) и тогда \(\Delta q_v=-\eta c_v \bar g_v\). После этого отдельно пояснить, что если каждый \(g_b\perp q_v\), то и сумма/среднее тоже \(\perp q_v\).

### ПРОБЛЕМА: Неявные условия (i.i.d. batch formation / фиксированное распределение, \(\|q\|>0\), “convergent training”) не заявлены как предпосылки
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально:
  - \(\|q\|>0\) действительно нужно для формул вида \(\Delta(s)=c/s\) и \(\|\nabla_q L(q)\|\propto 1/\|q\|\). В тексте это нигде не вынесено как явное условие (и padding/спец-токены иногда реально делают нулевые строки на практике).
  - Конструкция “Two runs on the same randomness” фактически задаёт конкретное семейство распределений через residual \(r\) и \(\gamma\), но “i.i.d. по времени” и прочие режимы формирования батчей в реальных системах действительно не проговорены как область применимости.
  - “convergent training process / statistically suppressed / low-probability event” в `appendix_note_on_c_variability.tex` и `appendix_note_on_batch_difference.tex` написано не как теорема с условиями/оценками, а как интуитивная оговорка.
- Что преувеличено: часть про “i.i.d. и путь в симплексе” у вас частично уже закрыта определением residual \(r\) в `appendix_note_on_distributions.tex`; проблема скорее в том, что это не поднято в формулировки результатов/теорем.
- Реальная severity: WEAK_REJECT (потому что в сумме создаёт ощущение “hidden assumptions”, но само по себе легко чинится явными оговорками и уточнением scope)

### ПРОБЛЕМА: “Монотонность по \(p_i\)” не формализована как путь в симплексе распределений
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: в тексте Appendix D сказано “differing only in \(p_i\): \(p_i'<p_i''\)”, что формально неполно без описания, как меняются остальные вероятности.
- Что преувеличено: у вас уже есть корректная формализация через residual \(r_k=\frac{p_k}{1-p_i}\) и параметр \(p\) в `appendix_note_on_distributions.tex` (то есть “математический объект” определён).
- Реальная severity: MINOR/WEAK_REJECT (зависит от того, насколько центральным вы позиционируете именно “nondecreasing in \(p_i\)” как строгую теорему; после фикса coupling-части станет MINOR)

### ПРОБЛЕМА: Список 4 условий в summary подменяет строгие условия на разговорные (неочевидная эквивалентность условиям на \(J_iJ_j^\top\))
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: в `collinearity.tex` условия (i)–(ii) сформулированы строго через \(J_iJ_j^\top\), а в `orthogonal_motion_summary.tex` это пересказано как “dedicated, non-shared parameter row”, что может быть понято шире/иначе, чем требуется доказательству.
- Что преувеличено: как “инженерная” интуиция summary помогает, и у вас в тексте уже есть строгая версия (i)–(ii); нужно просто синхронизировать формулировки.
- Реальная severity: MINOR

### ПРОБЛЕМА: Перегрузка символа \(c\) (count / cosine / gradient-magnitude factor) и мелкие нотационные несогласованности
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна (она уже фактически привела к путанице в обсуждениях)
- Severity: MINOR
- Направление исправления: переименовать хотя бы одну из трёх сущностей: например, \(n_v\) — count в батче, \(c_i(q)\) оставить для cosine или наоборот, а \(c=\eta^2\|Pu\|^2\) переименовать в \(\kappa\)/\(C_t\). Также унифицировать \(\partial F/\partial c_i\) vs \(\partial F/\partial \cos_i\) (в `appendix_note_on_c_variability.tex` сейчас это смена обозначений внутри одной цепочки рассуждений).

---

## ИТОГОВАЯ СВОДКА
ВАЛИДНЫХ: 3 из 7
ТРЕБУЮТ ИСПРАВЛЕНИЯ:
- Coupling-доказательство pathwise dominance при \(c'\neq c''\) (критично)
- Индексы item-id vs batch-slot (системно)
- Формула обновления embedding при повторах item в батче (формально)
- (минорно) перегрузка \(c\) и согласованность обозначений производных

МОЖНО ЗАЩИТИТЬ В REBUTTAL:
- Часть замечаний про “путь в симплексе” (уже есть `appendix_note_on_distributions.tex`, надо поднять в формулировку)
- Часть замечаний про summary-формулировки условий (есть строгая версия (i)–(ii), нужно синхронизировать текст)

</DEFENDER_1>

<DEFENDER_2>

# DEFENDER 2: Генератор контраргументов для rebuttal

**Репутация:** 50+ review cycles на топ-конференциях. Знаю, как отвечать рецензентам.

---

## ЧАСТЬ 1: ПРОБЛЕМЫ, ТРЕБУЮЩИЕ ИСПРАВЛЕНИЯ В СТАТЬЕ

---

### ПРОБЛЕМА: Coupling-доказательство монотонности при $c' \neq c''$
СТАТУС: Требует исправления в статье, не в rebuttal.

ЧЕРНОВИК REBUTTAL: 
"""
We thank the reviewer for the careful reading of Appendix D. The reviewer correctly identifies that pathwise dominance requires order preservation when $c' \neq c''$, which our current proof does not fully establish.

We have revised the theoretical claim in two ways:

1. **Weakened formulation:** We now state the result as monotonicity *in expectation* rather than almost-sure pathwise dominance. Specifically, since items with higher sampling probability $p_i$ receive more updates on average, and each update increases $\|q_i\|^2$ by a positive amount $\Delta(s) > 0$, the expected norm $\mathbb{E}[\|q_i^{(T)}\|]$ is nondecreasing in $p_i$.

2. **Added explicit condition:** We introduce assumption (A5): the gradient magnitude factor $c_t = \eta^2 \|P_t u_t\|^2$ satisfies $|c_t' - c_t''| \leq \delta(s_t'' - s_t')$ for coupled runs, where $\delta < 1$. Under this condition, order preservation holds: if $s' \leq s''$, then $s' + c'/s' \leq s'' + c''/s''$ provided the difference in $c$ is bounded relative to the difference in $s$.

The empirical frequency–norm correlations (0.66, 0.56 in Table 2) validate this mechanism regardless of the exact formal formulation.
"""

---

### ПРОБЛЕМА: Несогласованность индексов (item-id vs batch-slot)
СТАТУС: Требует исправления в статье, не в rebuttal.

ЧЕРНОВИК REBUTTAL:
"""
We thank the reviewer for noting the notational ambiguity. We have revised the manuscript to consistently distinguish:
- $b \in \{1, \ldots, B\}$ — batch slot index (used for $g_b$, $J_b$ in the dynamics equation)
- $v \in \{1, \ldots, N\}$ — item identity (used for $q_v$, $s^{(t)}_v$ in the coupling argument)

Specifically, in Section 2.4 and Appendix A, we now write $x_b$ for the item-id in batch slot $b$, making clear that $\Delta q_v = -\eta \sum_{b: x_b = v} g_b$ is a sum over all batch slots containing item $v$.
"""

---

### ПРОБЛЕМА: Неверная формула $\Delta q_i = -\eta c_i g_i$ при повторах item в батче
СТАТУС: Требует исправления в статье, не в rebuttal.

ЧЕРНОВИК REBUTTAL:
"""
We thank the reviewer for this precise observation. The reviewer is correct that when item $v$ appears $c_v > 1$ times in the batch, the correct update is:
$$\Delta q_v = -\eta \sum_{b: x_b = v} g_b$$
where each $g_b$ depends on the paired item in that training instance.

We have revised Eq. (10) accordingly. As the reviewer notes, this does not affect Proposition 2.6: since each $g_b \perp q_v$ (by the cosine-loss orthogonality lemma), their sum is also orthogonal to $q_v$. The revision improves precision without changing the main result.
"""

---

### ПРОБЛЕМА: Перегрузка символа $c$
СТАТУС: Требует исправления в статье, не в rebuttal.

ЧЕРНОВИК REBUTTAL:
"""
We thank the reviewer for highlighting the notational overload. We have revised the notation:
- $n_v$ — count of item $v$ in the batch (previously $c_i$ in Section 2.4)
- $\rho_i(q) = \cos(q, k_i)$ — cosine similarity (previously $c_i(q)$ in Appendix C)
- $\kappa_t = \eta^2 \|P_t u_t\|^2$ — gradient magnitude factor (previously $c$ in Appendix D/G)

This eliminates the ambiguity that arose when reading Appendices C, D, and G in sequence.
"""

---

## ЧАСТЬ 2: ПРОБЛЕМЫ ДЛЯ ЗАЩИТЫ В REBUTTAL

---

### ПРОБЛЕМА: Неявные условия ($\|q\| > 0$, i.i.d. batch formation, "convergent training")

REBUTTAL RESPONSE:
"""
We thank the reviewer for requesting explicit statement of these conditions.

**1) $\|q_i^{(0)}\| > 0$:** Standard random initialization (e.g., Xavier, He, or uniform) produces $\|q_i^{(0)}\| > 0$ almost surely. Padding tokens with zero embeddings are excluded from the loss computation in practice, so this condition is satisfied in all standard training setups. We have added this as an explicit assumption in the revised Section 3.

**2) i.i.d. batch formation:** The coupling construction in Appendix D explicitly uses i.i.d. sampling from distribution $p$ at each step. This is stated in the opening of Appendix D ("at each step $t$... draw the same random number $U$"). We have made this more prominent by adding "(batches formed by i.i.d. sampling)" to the main claim in Section 3.

**3) Bounded gradient regime:** We acknowledge that "convergent training process" in Appendix G was stated informally. We now frame this as a standard assumption: for InfoNCE with temperature $\tau$, the derivatives $|\partial F/\partial c_i| \leq 1/\tau$ are bounded (softmax outputs are in $[0,1]$). Combined with bounded batch size $m$, we have $\|u\| \leq m/\tau$, making $\kappa = \eta^2 \|Pu\|^2 \leq \eta^2 m^2/\tau^2$ uniformly bounded. This is now stated explicitly in Appendix G.
"""

ТАКТИКА: Clarify + Concede-and-pivot
- Clarify: показать, что условия либо уже есть (i.i.d.), либо выполняются автоматически ($\|q\| > 0$)
- Concede-and-pivot: признать informal language, добавить явные bounds для InfoNCE

СИЛА ОТВЕТА: STRONG

РИСК: Рецензент может запросить формальное доказательство boundedness для general cosine-based loss (не только InfoNCE). Ответ: "We restrict the formal claim to losses with bounded derivatives, which includes InfoNCE and all softmax-based contrastive losses."

---

### ПРОБЛЕМА: "Монотонность по $p_i$" не формализована как путь в симплексе

REBUTTAL RESPONSE:
"""
We thank the reviewer for this observation. The path in the probability simplex is indeed specified in Appendix E (Note on distributions), which defines the residual distribution:
$$r_k = \frac{p_k}{1 - p_i} \quad (k \neq i)$$
and the family of distributions parameterized by $p_i$:
$$\mathbb{P}^{(p_i)}\{X = k\} = (1 - p_i) r_k \quad (k \neq i)$$

This is the standard construction for varying a single coordinate $p_i$ while keeping the relative proportions of other items fixed. We have added a forward reference from the main claim in Section 3 to Appendix E, making explicit that "nondecreasing in $p_i$" refers to this parameterized family.
"""

ТАКТИКА: Redirect
- Показать, что формализация уже присутствует в Appendix E, просто не была явно связана с main claim

СИЛА ОТВЕТА: STRONG

РИСК: Минимальный. Appendix E содержит корректную формализацию; нужна только явная ссылка.

---

### ПРОБЛЕМА: Список условий в summary подменяет строгие условия на разговорные

REBUTTAL RESPONSE:
"""
We thank the reviewer for noting the potential mismatch between the formal conditions (i)–(ii) in Section 2.4 and the summary formulation in Section 2.6.

The precise equivalence is as follows:
- **Formal condition (i):** $J_i J_j^\top = 0$ for $i \neq j$
- **Formal condition (ii):** $J_i J_i^\top = \alpha_i I_d$

For embeddings layer (Appendix A.1), (i)–(ii) hold when each item $i$ has a dedicated parameter row $E_i$. For linear layer (Appendix A.2), (i)–(ii) hold when inputs are orthogonal ($x_i^\top x_j = 0$ for $i \neq j$) and each input maps to a unique parameter subset.

The summary phrase "dedicated, non-shared parameter row" is intended as an intuitive description for practitioners. We have revised Section 2.6 to include a parenthetical: "(formally: conditions (i)–(ii) from Section 2.4 hold)" to bridge the gap between the rigorous and intuitive formulations.
"""

ТАКТИКА: Clarify
- Объяснить точную связь между формальными условиями и summary-формулировкой
- Добавить явную ссылку на (i)–(ii) в summary

СИЛА ОТВЕТА: MEDIUM

РИСК: Рецензент может указать, что "dedicated parameter row" не достаточно для условия (ii) $J_i J_i^\top = \alpha_i I_d$ (изотропия). Ответ: "For the two encoder types we analyze (embedding layer, orthogonal-input linear layer), dedicated rows indeed imply both (i) and (ii). We do not claim this for arbitrary encoders."

---

## ЧАСТЬ 3: ДОПОЛНИТЕЛЬНЫЕ ЗАЩИТЫ

---

### ПРОБЛЕМА: $d = 1$ (одномерные эмбеддинги) — граничный случай

REBUTTAL RESPONSE:
"""
We thank the reviewer for noting this edge case. For $d = 1$, when $q$ and $k$ have the same sign, $\cos(q, k) = 1$ and the gradient is indeed zero. This is a degenerate case where the embedding is already optimal (maximal cosine), and no update occurs.

We have added a footnote: "The analysis assumes $d \geq 2$; the case $d = 1$ is degenerate as the only orthogonal direction to a scalar is zero."

This does not affect practical relevance since embedding dimensions in recommendation systems are typically $d \in [64, 768]$.
"""

ТАКТИКА: Scope defense
- Показать, что граничный случай тривиален и не относится к практике

СИЛА ОТВЕТА: STRONG

РИСК: Нет. $d = 1$ действительно вырожден, и никто не использует одномерные эмбеддинги.

---

### ПРОБЛЕМА: Cauchy-Schwarz не упомянут для $\|u\|^2 \geq (\hat{q}^\top u)^2$

REBUTTAL RESPONSE:
"""
We thank the reviewer for this suggestion. We have added a clarifying sentence in Appendix C after Eq. (76): "By Cauchy-Schwarz, $|\hat{q}^\top u| \leq \|\hat{q}\| \cdot \|u\| = \|u\|$, so $(\hat{q}^\top u)^2 \leq \|u\|^2$ and the square root is real."
"""

ТАКТИКА: Concede-and-pivot
- Признать minor omission, добавить одну строку

СИЛА ОТВЕТА: STRONG

РИСК: Нет. Это тривиальное уточнение.

---

### ПРОБЛЕМА: Boxed equality после linearization без пометки "first-order approx"

REBUTTAL RESPONSE:
"""
We thank the reviewer for this observation. The boxed equation $\Delta q_i = J_i \Delta\theta$ in Section 2.1 is exact for parameter-linear encoders (the focus of our analysis), as stated in Section 2.2 and Appendix A. 

To avoid confusion, we have:
1. Changed the boxed equation to use $\approx$ with a subscript "first-order"
2. Added immediately below: "For parameter-linear encoders (Section 2.2), this is an exact equality."

This clarifies that while the derivation uses linearization, the result is exact for the encoder class we analyze.
"""

ТАКТИКА: Clarify
- Объяснить, что для parameter-linear encoders это точное равенство

СИЛА ОТВЕТА: STRONG

РИСК: Минимальный. Текст уже содержит это уточнение в `interim_focus.tex`.

---

## ИТОГОВАЯ СВОДКА

| Проблема | Тактика | Сила | Действие |
|----------|---------|------|----------|
| Coupling при $c' \neq c''$ | — | — | Исправить в статье |
| Несогласованность индексов | — | — | Исправить в статье |
| Формула обновления $\Delta q_i$ | — | — | Исправить в статье |
| Перегрузка символа $c$ | — | — | Исправить в статье |
| Неявные условия | Clarify + Concede | STRONG | Rebuttal + minor fix |
| Путь в симплексе | Redirect | STRONG | Rebuttal + add reference |
| Summary vs formal conditions | Clarify | MEDIUM | Rebuttal + add reference |
| $d = 1$ граничный случай | Scope defense | STRONG | Add footnote |
| Cauchy-Schwarz | Concede | STRONG | Add one line |
| Boxed equality | Clarify | STRONG | Add clarification |

---

**ОБЩАЯ СТРАТЕГИЯ REBUTTAL:**

1. **Честно признать главную проблему** (coupling при $c' \neq c''$) и предложить ослабленную формулировку "in expectation"
2. **Показать, что большинство "скрытых условий"** либо уже формализованы (i.i.d. в Appendix E), либо выполняются автоматически ($\|q\| > 0$), либо легко добавляются (bounded $\partial F/\partial c_i$ для InfoNCE)
3. **Подчеркнуть, что эмпирические результаты** (correlation 0.66, 0.56) валидируют механизм независимо от степени формальной строгости теории
4. **Минорные исправления** (нотация, граничные случаи, Cauchy-Schwarz) показывают внимание к деталям без ослабления main claims

---

**Подпись:** DEFENDER 2  
**Вердикт:** REBUTTAL ГОТОВ. Критическая проблема (coupling) требует исправления в статье; остальные проблемы защитимы.

</DEFENDER_2>
