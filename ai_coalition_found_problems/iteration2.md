<ATTACKER_1>

# ATTACKER 1: Логические дыры в доказательствах — Iteration 2

**Rejection rate: 80%. Репутация: нахожу фатальные логические дыры, которые другие пропускают.**

---

## ОЦЕНКА ИЗМЕНЕНИЙ

Статья существенно переработана после iteration 1:
- ✅ Исправлена формула обновления в collinearity.tex (теперь сумма по вхождениям)
- ✅ Явно указаны дополнительные условия (i.i.d. sampling, bounded derivatives)
- ✅ Формализовано семейство распределений в appendix_note_on_distributions.tex
- ✅ Разобран контрпример рецензента
- ⚠️ Coupling-аргумент полностью переписан — требует нового анализа

---

## ПРОБЛЕМА 1: Lemma "Expected Gap is Nonnegative" содержит non sequitur

### ЛОКАЦИЯ:
Appendix D (appendix_coupling_popularity.tex), Section "Key Observation", строки 63-112, особенно строки 101-109

### SEVERITY: REJECT

### СУТЬ:
Доказательство Lemma~\ref{lemma:expected-gap} утверждает:
> "Since (E1) always increases the gap and occurs with positive probability, while (E2) has bounded effect, the expected gap increment $\mathbb{E}[\Delta D_t | \mathcal{H}_t] \geq 0$ when $D_t \geq 0$."

Это **non sequitur**. Из того, что:
1. (E1) даёт положительный вклад с положительной вероятностью
2. (E2) имеет ограниченный эффект

**НЕ СЛЕДУЕТ**, что $\mathbb{E}[\Delta D_t] \geq 0$.

### ПОЧЕМУ ЭТО ФАТАЛЬНО:
Для доказательства $\mathbb{E}[\Delta D_t] \geq 0$ нужно показать количественно:
$$\mathbb{P}(\text{E1}) \cdot \mathbb{E}[\Delta D_t | \text{E1}] + \mathbb{P}(\text{E2}) \cdot \mathbb{E}[\Delta D_t | \text{E2}] \geq 0$$

Авторы показали $\mathbb{E}[\Delta D_t | \text{E1}] > 0$, но **не оценили** $\mathbb{E}[\Delta D_t | \text{E2}]$. Под (E2) $\Delta D_t$ может быть **отрицательным** (когда $c' > c''$), и если (E2) происходит достаточно часто с достаточно отрицательным вкладом, сумма может быть отрицательной.

### КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ:
Рассмотрим случай $p'_i$ близко к $p''_i$ (малое $\Delta p$).

**Вероятности:**
- $\mathbb{P}(\text{E1})$: exclusive slots без shared slots ≈ $O(\Delta p)$
- $\mathbb{P}(\text{E2})$: хотя бы один shared slot ≈ $1 - (1-p'_i)^B$ (константа, если $p'_i$ не слишком мало)

**Вклады:**
- $\mathbb{E}[\Delta D_t | \text{E1}] = O(c/s) > 0$
- $\mathbb{E}[\Delta D_t | \text{E2}] = c''/s'' - c'/s'$ — может быть любого знака

Если (E2) происходит с константной вероятностью, а (E1) с $O(\Delta p)$, и $\mathbb{E}[\Delta D_t | \text{E2}] < 0$ в среднем (что возможно при определённых батч-композициях), то:
$$\mathbb{E}[\Delta D_t] \approx O(\Delta p) \cdot O(c/s) + O(1) \cdot (\text{negative})$$

При достаточно малом $\Delta p$ это **может быть отрицательным**.

---

## ПРОБЛЕМА 2: Lemma "Eventual Dominance" содержит внутреннее противоречие

### ЛОКАЦИЯ:
Appendix D (appendix_coupling_popularity.tex), Section "Strengthening: Almost Sure Eventual Dominance", строки 114-165, особенно строки 131-152

### SEVERITY: REJECT

### СУТЬ:
Авторы утверждают (строка 131):
> "Once $D_t > 0$, we show it stays positive."

Но затем в case analysis (строки 148-151):
> "If $c'' < c'$: The gap may decrease... $D_{t+1} \geq D_t - 2c_{max}/s_{min}$."

**Противоречие:** Если $D_t < 2c_{max}/s_{min}$, то по этой формуле $D_{t+1}$ может стать **отрицательным**. Это прямо противоречит утверждению "stays positive".

### ПОЧЕМУ ЭТО ФАТАЛЬНО:
Lemma "Eventual Dominance" используется для доказательства Theorem "Popularity-Norm Monotonicity". Если gap может переходить через ноль многократно, "eventually almost sure" не следует из представленных аргументов.

### КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ:
Пусть после первого (E1) события $D_{\tau_1} = \epsilon$ для малого $\epsilon > 0$.

На следующем шаге происходит (E2) с $c' - c'' > \epsilon \cdot s'$. Тогда:
$$D_{\tau_1 + 1} \approx D_{\tau_1} + \frac{c''}{s''} - \frac{c'}{s'} < D_{\tau_1} - \frac{c' - c''}{s'} < 0$$

Gap стал отрицательным. Утверждение "stays positive" **ложно**.

Авторы пытаются это обойти через "racing dynamics" (строки 154-164), но не дают формального доказательства того, что накопленные (E1) events доминируют над (E2) decrements.

---

## ПРОБЛЕМА 3: Формула (87) в доказательстве Lemma~\ref{lemma:expected-gap} ошибочна

### ЛОКАЦИЯ:
Appendix D (appendix_coupling_popularity.tex), строки 85-88

### SEVERITY: WEAK_REJECT

### СУТЬ:
Формула под event (E2):
$$\Delta D_t = \left(s''_t + \frac{c''_t}{s''_t}\right) - \left(s'_t + \frac{c'_t}{s'_t}\right) = \frac{c''_t}{s''_t} - \frac{c'_t}{s'_t} + (s''_t - s'_t)\left(1 - \frac{1}{s''_t} - \frac{1}{s'_t}\right)$$

**Проверка:** 
$$\left(s'' + \frac{c''}{s''}\right) - \left(s' + \frac{c'}{s'}\right) = (s'' - s') + \frac{c''}{s''} - \frac{c'}{s'}$$

Это **не равно** тому, что написано авторами. Член $(s'' - s')(1 - 1/s'' - 1/s')$ — откуда он взялся?

Правильная формула:
$$\Delta D_t = D_t + \frac{c''}{s''} - \frac{c'}{s'}$$

где $D_t = s'' - s'$. То есть **изменение** gap'а:
$$\Delta D_t = \frac{c''}{s''} - \frac{c'}{s'}$$

### ПОЧЕМУ ЭТО СЕРЬЁЗНО:
Ошибка в базовой формуле подрывает всё последующее рассуждение о "bounded effect" события (E2).

### ИСПРАВЛЕНИЕ:
Заменить формулу (87) на:
$$\Delta D_t = \frac{c''_t}{s''_t} - \frac{c'_t}{s'_t}$$

---

## ПРОБЛЕМА 4: "Racing dynamics" — неформализованная эвристика

### ЛОКАЦИЯ:
Appendix D (appendix_coupling_popularity.tex), строки 154-164

### SEVERITY: WEAK_REJECT

### СУТЬ:
Аргумент о том, что (E1) events накапливают gap, а (E2) events убирают bounded amount, остаётся **неформализованным**:

> "Between (E2) events, (E1) events accumulate gap... After sufficiently many steps, the accumulated (E1) contributions dominate any (E2) decrements."

Это требует доказательства, а не утверждения. Нужно показать:
1. Ожидаемое число (E1) events за интервал между (E2) events
2. Ожидаемый накопленный вклад от (E1) за этот интервал
3. Что этот вклад превышает максимальный decrement от (E2)

### ПОЧЕМУ ЭТО СЕРЬЁЗНО:
Без формального анализа соотношения частот (E1) и (E2) и их вкладов, утверждение "eventually permanent dominance" — это гипотеза, а не теорема.

---

## ПРОБЛЕМА 5: Перегрузка символа $c$ не исправлена

### ЛОКАЦИЯ:
- appendix_cosine_gradient_magnitude.tex, строка 41: $c_i(q) = \cos(q,k_i)$
- appendix_coupling_popularity.tex, строка 34: $c = \eta^2 \|Pu\|^2$

### SEVERITY: MINOR

### СУТЬ:
Один символ $c$ всё ещё используется для двух разных величин: cosine similarity и gradient magnitude factor. Это создаёт путаницу при чтении appendices.

### ИСПРАВЛЕНИЕ:
Переименовать: $\rho_i(q) = \cos(q,k_i)$ для cosines, $\kappa = \eta^2\|Pu\|^2$ для gradient factor.

---

## ПРОБЛЕМА 6: Условие $\|q\| > 0$ по-прежнему не указано явно

### ЛОКАЦИЯ:
- appendix_cosine_gradient_magnitude.tex: формула делит на $\|q\|$
- appendix_coupling_popularity.tex: $\Delta(s) = c/s$ не определено при $s = 0$

### SEVERITY: MINOR

### СУТЬ:
Все формулы требуют $\|q\| > 0$ (или $s > 0$), но это нигде не указано как явное условие теоремы.

### ИСПРАВЛЕНИЕ:
Добавить в Theorem: "We assume $\|q_i^{(0)}\| > 0$ (satisfied by standard random initialization)."

---

## ИТОГОВЫЙ СТАТУС

**НЕ ЧИСТО.**

Обнаружены проблемы уровня REJECT:

| № | Проблема | Severity |
|---|----------|----------|
| 1 | Non sequitur в доказательстве Lemma "Expected Gap is Nonnegative" | REJECT |
| 2 | Внутреннее противоречие в Lemma "Eventual Dominance" | REJECT |
| 3 | Ошибка в формуле (87) | WEAK_REJECT |
| 4 | "Racing dynamics" — неформализованная эвристика | WEAK_REJECT |
| 5 | Перегрузка символа $c$ | MINOR |
| 6 | $\|q\| > 0$ не указано | MINOR |

**Центральный claim** — "expected embedding norm is nondecreasing in $p_i$" — **по-прежнему не доказан строго**.

Переработка coupling-аргумента ввела новую структуру (события E0/E1/E2), но:
1. Доказательство Lemma "Expected Gap is Nonnegative" содержит логическую дыру (non sequitur)
2. Доказательство Lemma "Eventual Dominance" противоречит само себе ("stays positive" vs "may decrease")
3. "Racing dynamics" остаётся эвристикой

---

## РЕКОМЕНДАЦИИ ДЛЯ ИСПРАВЛЕНИЯ

### Вариант A: Полностью формализовать "racing dynamics"

1. Вычислить явно $\mathbb{E}[\text{(E1) events между (E2) events}]$
2. Показать, что накопленный вклад $\sum_{\text{E1}} c/s$ превышает $2c_{max}/s_{min}$
3. Применить renewal theory или martingale arguments

### Вариант B: Ослабить claim до "in expectation" без "eventual dominance"

Доказать только:
$$\mathbb{E}[s''^{(T)}] \geq \mathbb{E}[s'^{(T)}]$$

Для этого достаточно показать, что run'' получает **больше обновлений в среднем** (что очевидно из конструкции coupling), и каждое обновление увеличивает $s$ на положительную величину.

Это **не требует** сравнения gap'ов на каждом шаге — только общего подсчёта:
$$\mathbb{E}[s^{(T)}] = s^{(0)} + \sum_{t=0}^{T-1} \mathbb{E}[\mathbf{1}_{\{i \in \text{batch}_t\}} \cdot c_t/s_t]$$

При большем $p_i$ — больше $\mathbb{E}[\mathbf{1}_{\{i \in \text{batch}\}}]$ — больше ожидаемая сумма.

### Вариант C: Использовать stochastic dominance напрямую

Показать, что $s''^{(T)} \succeq_{st} s'^{(T)}$ (stochastic dominance) без pathwise coupling.

Это может быть проще, чем пытаться доказать pathwise dominance с возможными reversals.

---

## СРАВНЕНИЕ С ITERATION 1

| Проблема | Iteration 1 | Iteration 2 |
|----------|-------------|-------------|
| Coupling при $c' \neq c''$ | Индукция ломается | Переформулировано, но новое доказательство неполное |
| Формула обновления | $\Delta q_i = -\eta c_i g_i$ (неверно) | Исправлено на сумму |
| i.i.d. batch formation | Не указано | Указано явно |
| Bounded derivatives | Не указано | Указано явно |
| Путь в симплексе | Не формализовано | Формализовано |

**Прогресс есть**, но центральная проблема — строгость coupling-аргумента — **не решена**.

---

**Подпись:** ATTACKER 1  
**Вердикт:** REJECT (логические дыры в переработанном coupling-доказательстве)

</ATTACKER_1>

<ATTACKER_3>

# ATTACKER 3: Формальная строгость и consistency (iteration 1)

**Роль:** Профессор математики ETH Zürich. Фокус: нотация, кванторы, согласованность определений.

---

## ПРОБЛЕМА 1: Индексация в `one_formula.tex` не разделяет batch-slot и item-id

**ЛОКАЦИЯ:** `final_tex_paper_in_this_folder_icml26_iteration1/sections/one_formula.tex`, строки 10–35

**SEVERITY:** WEAK_REJECT

**ПРОБЛЕМА:** В строке 10 определяется "$g_j$ loss gradient w.r.t. the encoder output $q_j$ for the $j$-th example in the batch". Затем в строке 35 используется $\Delta q_i$ без явного пояснения, что $i$ это также индекс примера батча (а не item-id). В дальнейших секциях (`norm_growth_vs_popularity.tex`, coupling) $q_i$ используется как "embedding item'а $i$", создавая конфликт нотации.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The indexing convention is inconsistent: in Section 2.1, subscript $i$ denotes batch position, but in Section 3 and Appendix D, the same subscript $i$ denotes item identity. This makes statements like $q_i^{(t)}$ in the coupling argument ambiguous."

**ИСПРАВЛЕНИЕ:** Ввести разные индексы: $b \in \{1, \ldots, B\}$ для batch slots (где определяются $g_b, J_b$), и $v \in \{1, \ldots, N\}$ для item-id (где определяются $q_v, s_v^{(t)}$). В `one_formula.tex` использовать $g_b, J_b$, и явно написать, что для item $v$ имеем $\Delta q_v = \sum_{b:\, x_b = v} (\text{contribution from slot } b)$.

---

## ПРОБЛЕМА 2: В `appendix_encoders.tex` фраза "$x_i$ -- index of example $i$" усугубляет путаницу

**ЛОКАЦИЯ:** `final_tex_paper_in_this_folder_icml26_iteration1/sections/appendix_encoders.tex`, строка 4

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Написано "\textbf{Input:} $x_i = i \in \{1,\dots,N\}$ \;($x_i$ -- index of example $i$)". Это буквально означает "$x_i$ is the index of example $i$", что создаёт циклическое определение ($i$ — индекс чего? Если "$i$" это "example index", то "$x_i = i$" означает "input of example $i$ is $i$" — это тавтология). На самом деле авторы хотели сказать "$x_i$ is the item-id for example $i$", но это не следует из текста.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "Appendix A.1, line 4: the notation '$x_i = i$ ($x_i$ -- index of example $i$)' is circular and does not clarify whether $i$ is a batch position or an item identifier."

**ИСПРАВЛЕНИЕ:** Переписать как: "\textbf{Input:} For batch position $b$, let $x_b \in \{1, \ldots, N\}$ denote the item-id. For an embedding layer, $x_b$ is a discrete index selecting the row of the embedding matrix $E$." Альтернативно: "$x_i$ is the item identity (row index in $E$) for the training example."

---

## ПРОБЛЕМА 3: Перегрузка символа $c$ сохранилась (count vs cosine vs gradient-magnitude factor)

**ЛОКАЦИЯ:** 
- `appendix_cosine_gradient_magnitude.tex`, строка 41: $c_i(q) = \cos(q, k_i)$
- `appendix_note_on_c_variability.tex`, строка 17: $c = \eta^2 \|Pu\|^2$
- `appendix_coupling_popularity.tex`, строка 174: $|\partial F / \partial c_s| \leq M$

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Символ $c$ используется для трёх разных величин:
1. Косинус: $c_i(q) = \cos(q, k_i)$ (Appendix C, строка 41)
2. Gradient magnitude factor: $c = \eta^2 \|Pu\|^2$ (Appendix G, строка 17; Appendix D, строка 34)
3. В `appendix_coupling_popularity.tex` (строка 174) внезапно появляется $c_s$ в контексте производной $\partial F/\partial c_s$, где ранее (Appendix C) использовалось $c_i$.

Дополнительно: в старых версиях $c_i$ означал count (число вхождений item в батч), но в iteration1 это исправлено на суммирование по слотам. Однако нотация $c$ для разных сущностей остаётся перегруженной.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The symbol $c$ is overloaded: it denotes cosine similarity ($c_i(q)$ in Appendix C), gradient magnitude factor ($c$ in Appendix D/G), and the subscript varies inconsistently ($c_i$ vs $c_s$ in derivative notation). This hinders readability in proof-heavy sections."

**ИСПРАВЛЕНИЕ:** Переименовать хотя бы одну из величин: например, $\rho_i(q) = \cos(q, k_i)$ для косинуса, сохранить $c = \eta^2 \|Pu\|^2$ для gradient magnitude factor, и унифицировать индексацию в производных ($\partial F/\partial \rho_i$ везде, где речь про косинусы).

---

## ПРОБЛЕМА 4: Перегрузка символа $\tau$ (температура InfoNCE vs время события)

**ЛОКАЦИЯ:** 
- `appendix_coupling_popularity.tex`, строка 94: $c_{\max} = \eta^2 m^2/\tau^2$
- `appendix_coupling_popularity.tex`, строка 129: $\tau_1$ (время первого события E1)

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Символ $\tau$ используется в двух контекстах:
1. Как параметр температуры InfoNCE (строка 94)
2. Как обозначение времени (строка 129: "$\tau_1$" — время первого наступления события E1)

Это разные объекты (скаляр vs случайная величина), но используют одну букву.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The symbol $\tau$ is used for both the InfoNCE temperature parameter (line 94) and the stopping time $\tau_1$ (line 129), creating notational collision."

**ИСПРАВЛЕНИЕ:** Использовать $T$ для температуры InfoNCE (или явно написать "temperature" при первом упоминании), и $\tau$ оставить для stopping times.

---

## ПРОБЛЕМА 5: Температура $\tau$ используется без определения

**ЛОКАЦИЯ:** `appendix_coupling_popularity.tex`, строка 94

**SEVERITY:** MINOR

**ПРОБЛЕМА:** В строке 94 появляется "$c_{\max} = \eta^2 m^2/\tau^2$ (bounded gradient regime)", где $\tau$ явно относится к InfoNCE, но нигде ранее в тексте не определено, что такое $\tau$. Для читателя, не знакомого с InfoNCE, это undefined symbol.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The temperature parameter $\tau$ appears in Appendix D (line 94) without prior definition. While standard for InfoNCE, the paper does not define this notation."

**ИСПРАВЛЕНИЕ:** В `appendix_coupling_popularity.tex` (или ранее, в introduction/experiments) добавить footnote или явное определение: "For InfoNCE loss with temperature $\tau$, the derivatives $|\partial F/\partial c_i| \leq 1/\tau$."

---

## ПРОБЛЕМА 6: В `orthogonal_motion_summary.tex` условие (3) не ссылается на формальные (i)–(ii)

**ЛОКАЦИЯ:** `final_tex_paper_in_this_folder_icml26_iteration1/sections/orthogonal_motion_summary.tex`, строки 7–8

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Условие (3) гласит: "each distinct input has a dedicated, non-shared parameter row (no overlap across inputs)". Это упрощённая формулировка условий (i)–(ii) из `collinearity.tex`, но без явной ссылки. В результате читатель не понимает точную связь между "dedicated row" и операторными условиями $J_iJ_j^\top = 0$ для $i \neq j$ и $J_iJ_i^\top = \alpha_i I_d$.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The summary condition (3) ('dedicated, non-shared parameter row') is stated informally without referencing the precise operator conditions (i)–(ii) from Section 2.4. The equivalence is not obvious for general architectures."

**ИСПРАВЛЕНИЕ:** Добавить в `orthogonal_motion_summary.tex` после условия (3): "(formally: conditions (i)–(ii) from Section 2.4 hold)". Альтернативно, в `collinearity.tex` после вывода условий (i)–(ii) добавить: "For embedding layers and orthogonal-input linear layers, this is equivalent to each input owning a non-shared parameter row."

---

## ПРОБЛЕМА 7: "Claim" в `norm_growth_vs_popularity.tex` остался неформальным

**ЛОКАЦИЯ:** `final_tex_paper_in_this_folder_icml26_iteration1/sections/norm_growth_vs_popularity.tex`, строки 11–13

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Ключевое утверждение "The larger the embedding norm, the slower it grows under a cosine-based loss" подано как неформальный **Claim** без точных кванторов/условий. Непонятно:
- Для какого множества эмбеддингов $q$ это верно ($\|q\| > 0$?)
- Что такое "slower" формально (производная? скорость изменения нормы?)
- При каких предположениях на $F$, $k_i$?

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The Claim in Section 3 (lines 11–13) lacks formal statement: no quantifiers, no precise definition of 'slower', no explicit conditions ($\|q\| > 0$, etc.). For a proof-heavy paper, key lemmas should be stated rigorously."

**ИСПРАВЛЕНИЕ:** Переформулировать как **Lemma** с явными условиями:
> **Lemma (Norm–Growth Inverse Relation).** Let $L(q) = F(\cos(q, k_1), \ldots, \cos(q, k_m))$ be a cosine-based loss with differentiable $F$ and nonzero $k_i$. For any $q$ with $\|q\| > 0$, the gradient norm satisfies $\|\nabla_q L(q)\| = g(\|q\|) / \|q\|$ where $g(\|q\|)$ is independent of $\|q\|$. Thus, $\|\nabla_q L(q)\|$ decreases monotonically as $\|q\|$ grows, holding $\{k_i\}$ and $F$ fixed.

---

## ПРОБЛЕМА 8: Несогласованность нумерации условий (intro: A1–A4, conclusion: 1–5)

**ЛОКАЦИЯ:** 
- `introduction.tex`, строки 13–15: (A1)–(A4)
- `conclusion.tex`, строки 4–9: enumerate 1–5
- `appendix_coupling_popularity.tex`, строка 171: "four conditions from Section~2"

**SEVERITY:** MINOR

**ПРОБЛЕМА:** В introduction используется нумерация (A1), (A2), (A3), (A4), в conclusion используется enumerate без буквенных меток (просто 1, 2, 3, 4, 5), а в Theorem~\ref{thm:pathwise} (Appendix D, строка 171) упоминаются "four conditions from Section~2" (хотя в conclusion их пять). Это создаёт путаницу при ссылках.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The conditions are numbered inconsistently: (A1)–(A4) in Introduction, 1–5 in Conclusion, and referenced as 'four conditions' in Theorem (line 171 of Appendix D). Which set is canonical?"

**ИСПРАВЛЕНИЕ:** Унифицировать нумерацию: либо везде использовать (A1)–(A5), либо ввести две группы (архитектурные условия A1–A4 + практическое условие A5 про learning rate). В Theorem явно указать: "Under conditions (A1)–(A4) from Section~2, plus (A5): i.i.d. batch formation and bounded derivatives..."

---

## ПРОБЛЕМА 9: В coupling-доказательстве "$m$" не определён (batch size vs число косинусов)

**ЛОКАЦИЯ:** `appendix_coupling_popularity.tex`, строка 94: $c_{\max} = \eta^2 m^2/\tau^2$

**SEVERITY:** MINOR

**ПРОБЛЕМА:** В формуле $c_{\max} = \eta^2 m^2/\tau^2$ используется $m$ как "batch size", но ранее (в `appendix_cosine_gradient_magnitude.tex`, строка 35) $m$ определено как количество косинусов в loss-функции $L(q) = F(\cos(q, k_1), \ldots, \cos(q, k_m))$. Это разные величины: в two-tower системе количество косинусов = количество in-batch negatives, которое не обязательно равно batch size $B$ (введённому в `appendix_coupling_popularity.tex`, строка 13).

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "The symbol $m$ is used for two different quantities: the number of cosines in $F(\cos(q, k_1), \ldots, \cos(q, k_m))$ (Appendix C) and implicitly for batch size in the bound $c_{\max} = \eta^2 m^2/\tau^2$ (Appendix D). For InfoNCE with in-batch negatives, are these equal?"

**ИСПРАВЛЕНИЕ:** Явно определить связь между $m$ (число косинусов) и $B$ (batch size). Для InfoNCE обычно $m = B$ (один positive + $B-1$ negatives), но это нужно проговорить. Альтернативно, использовать разные буквы: $B$ для batch size, $m$ для числа косинусов.

---

## ПРОБЛЕМА 10: Квантор "almost surely" в Lemma~\ref{lemma:eventual} не подкреплён формализацией вероятностного пространства

**ЛОКАЦИЯ:** `appendix_coupling_popularity.tex`, строки 118–124 (Lemma "Eventual Dominance")

**SEVERITY:** WEAK_REJECT

**ПРОБЛЕМА:** Lemma утверждает существование (random) finite time $T_0 < \infty$ a.s., но вероятностное пространство $(\Omega, \mathcal{F}, \mathbb{P})$ нигде не определено явно. Доказательство апеллирует к "infinitely often almost surely" (строка 127), но формальное обоснование требует Borel–Cantelli lemma или подобных результатов, которые не процитированы. Для строгого математического текста утверждение "almost surely" без определения вероятностной модели — это weak reject.

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "Lemma 2 claims 'almost sure' convergence without defining the probability space. The proof invokes 'infinitely often a.s.' (line 127) but does not cite Borel–Cantelli or formally establish the event structure. For a theorem claiming a.s. properties, the probabilistic model must be explicit."

**ИСПРАВЛЕНИЕ:** В начале Appendix D явно определить вероятностное пространство:
> "Let $\Omega = [0,1]^\mathbb{N}$ be the space of sequences $(U_1, U_2, \ldots)$ of i.i.d. Uniform(0,1) random variables. The coupling construction defines a coupling of two Markov chains on $\Omega$..."

Затем в доказательстве Lemma~\ref{lemma:eventual} явно сослаться на второй Borel–Cantelli lemma (независимые события с $\sum_t \mathbb{P}(\text{E1 at step } t) = \infty$ происходят infinitely often a.s.).

---

## ПРОБЛЕМА 11: Boxed-равенство после linearization в `one_formula.tex` не помечено как первое приближение

**ЛОКАЦИЯ:** `final_tex_paper_in_this_folder_icml26_iteration1/sections/one_formula.tex`, строка 35

**SEVERITY:** MINOR

**ПРОБЛЕМА:** В строке 33 написано "we linearize the encoder around the current parameters and obtain", затем в строке 35 стоит boxed-равенство $\boxed{\Delta q_i = J_i \Delta\theta = \ldots}$. Для general encoders это первое приближение ($\approx$), а не точное равенство. Да, в `interim_focus.tex` поясняется, что для parameter-linear это точно, но локально читатель видит строгое равенство сразу после слова "linearize".

**КАК РЕЦЕНЗЕНТ ЭТО ИСПОЛЬЗУЕТ:** "Equation (starting-formula) is presented as an equality immediately after 'we linearize', which is misleading for general encoders. The caveat appears later in Section 2.2, but the boxed equation should indicate first-order approximation."

**ИСПРАВЛЕНИЕ:** Заменить знак равенства на $\approx$ в boxed-формуле, и добавить subscript "first-order":
```latex
\boxed{\; \Delta q_{i} \approx J_{i}\,\Delta\theta = -\eta \sum_{j} J_{i}\,J_{j}^{\!\top}\,g_{j} \;}_{\text{first-order}}
```
И непосредственно ниже добавить: "(Exact equality for parameter-linear encoders, see Section~2.2.)"

---

## ИТОГОВЫЙ СТАТУС

**НЕ ЧИСТО.** Обнаружены проблемы формальной строгости:

**WEAK_REJECT уровня:**
1. Несогласованность индексации (batch-slot vs item-id) — системная проблема
2. Квантор "almost surely" без определения вероятностного пространства

**MINOR уровня:**
3. Перегрузка символов $c$ и $\tau$
4. Undefined symbol $\tau$ (температура InfoNCE)
5. Неформальный "Claim" без кванторов
6. Несогласованность нумерации условий (A1–A4 vs 1–5)
7. Символ $m$ используется для разных величин
8. Boxed-равенство после "linearize" без пометки "first-order"
9. Условие (3) в summary не ссылается на (i)–(ii)
10. Путаница "$x_i$ -- index of example $i$"

**РЕКОМЕНДАЦИЯ:** Требуется систематическая ревизия нотации (особенно индексация и перегрузка символов) и формализация вероятностной модели для "almost sure" утверждений.

</ATTACKER_3>

<ATTACKER_2>

# ATTACKER 2: Неявные допущения и скрытые условия — Iteration 2

**Специализация:** Optimization theory (DeepMind). Цель: вытащить на свет все «молчаливые» условия, без которых теоремы/механизм не работают так, как заявлено.

---

### ПРОБЛЕМА 1: Неявное требование \(\|q\|>0\) и \(\|k\|>0\) (деление на ноль / недифференцируемость нормализации)
ЛОКАЦИЯ:
- `sections/appendix_cosine_lemma.tex`: “For any nonzero \(q,k\in\mathbb{R}^d\)” (не поднято в основные утверждения)
- `sections/appendix_cosine_gradient_magnitude.tex`: формулы с \(\hat q = q/\|q\|\), \(\hat k = k/\|k\|\) и \(\|\nabla_q L(q)\|\propto 1/\|q\|\)
- `sections/appendix_coupling_popularity.tex`: динамика \(s_{t+1}=s_t + c_t/s_t\)
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Везде предполагается, что ни один “участвующий” эмбеддинг не нулевой: \(\|q\|>0\), \(\|k\|>0\) (и, в терминах coupling, \(s>0\)).
ГДЕ ИСПОЛЬЗУЕТСЯ:
- Определение \(\hat q,\hat k\), проектор \(P=I-\hat q\hat q^\top\)
- Деление на \(\|q\|\) и на \(s\) в ключевых формулах
КОНТРПРИМЕР:
- Реальные пайплайны часто имеют “нулевые” строки (padding/UNK/removed items), либо эмбеддинги могут стать ~нулевыми из-за регуляризации/клиппинга/квантизации; тогда \(\hat q\) и \(\Phi(s)=s+c/s\) не определены, а формулы ортогональности/роста нормы теряют смысл.

---

### ПРОБЛЕМА 2: Неявное предположение про «чистую» формулу cosine без \(\varepsilon\)-стабилизации
ЛОКАЦИЯ:
- `sections/introduction.tex`, определение \(\cos(q,k)=\langle q,k\rangle/(\|q\|\,\|k\|)\)
- Вся цепочка “градиент ортогонален ⇒ при коллинеарности апдейта получаем ортогональный шаг”
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Косинус реализован строго как \(\frac{q^\top k}{\|q\|\|k\|}\), без практических модификаций вида \(\|q\|_\varepsilon=\sqrt{\|q\|^2+\varepsilon}\), clamp норм, stop-grad на норме, и т.п.
ГДЕ ИСПОЛЬЗУЕТСЯ:
- Лемма об ортогональности \(q^\top \nabla_q \cos(q,k)=0\) и вывод \(\Delta q \perp q\)
КОНТРПРИМЕР:
- В продакшене почти всегда есть \(\varepsilon\) в норме ради численной устойчивости; тогда \(q^\top \nabla_q \cos_\varepsilon(q,k)\) вообще говоря \(\neq 0\), и “строго ортогональные” траектории становятся лишь приближёнными (что ломает строгость утверждений про монотонность шага по Пифагору).

---

### ПРОБЛЕМА 3: Условие “i.i.d. batches” не уточняет независимость *внутри батча* и *по времени*
ЛОКАЦИЯ:
- `sections/appendix_coupling_popularity.tex`: coupling по слотам батча через \(U_b\) (явно предполагает независимость по \(b\))
- `sections/appendix_note_on_distributions.tex`: конструкция через \(U\sim\mathrm{Uniform}(0,1)\) и \(Z\sim\mathrm{Cat}(r)\)
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: В доказательной части фактически нужно более сильное утверждение, чем “i.i.d. sampling”: независимость по слотам батча (with replacement) и независимость между шагами \(t\) (нет зависимостей от прошлых батчей/истории).
ГДЕ ИСПОЛЬЗУЕТСЯ:
- Биномиальная модель \(|E_t|\sim\mathrm{Binomial}(B,\Delta p)\) и “independent across steps”
КОНТРПРИМЕР:
- Sampling without replacement внутри эпохи, hard-negative mining, session-based streaming, “repeat avoidance”, кешированные негативы → нарушают независимость и/или идентичность распределения, и coupling/оценки частот событий (E0/E1/E2) перестают быть корректными.

---

### ПРОБЛЕМА 4: “Bounded derivatives (InfoNCE)” скрыто требует \(\tau>0\) и отсутствия annealing \(\tau\to 0\)
ЛОКАЦИЯ:
- `sections/appendix_coupling_popularity.tex`: “Loss has bounded derivatives … (satisfied by InfoNCE)”
- `sections/appendix_note_on_batch_difference.tex`: оценка вероятности больших различий в \(c\)
SEVERITY: MINOR
НЕЯВНОЕ ДОПУЩЕНИЕ: Температура \(\tau\) фиксирована и ограничена снизу: \(\tau\ge\tau_{\min}>0\), иначе bound вида \(|\partial F/\partial \cos|\le 1/\tau\) не даёт универсальной константы.
ГДЕ ИСПОЛЬЗУЕТСЯ:
- Любые “bounded \(c_t\)”/“bounded effect” аргументы через \(c_{\max}=\eta^2 m^2/\tau^2\)
КОНТРПРИМЕР:
- \(\tau\)-annealing (или learnable \(\tau\)) с \(\tau\to 0\) делает производные arbitrarily large → \(c_t\) и различия \(c'_t-c''_t\) могут стать неконтролируемыми.

---

### ПРОБЛЕМА 5: Неявное “no sharing” сильнее, чем звучит: даже общий bias/LayerNorm ломает предпосылку
ЛОКАЦИЯ:
- `sections/orthogonal_motion_summary.tex`: пункт про “dedicated, non-shared parameter row”
- `sections/parameter_linear_encoder.tex` + `sections/appendix_encoders.tex`: обсуждение линейных/embedding энкодеров
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: На стороне item tower нет *никаких* общих параметров, включая общий bias, LayerNorm-параметры, shared projection head, общие lookup-таблицы по признакам, и т.п.
ГДЕ ИСПОЛЬЗУЕТСЯ:
- В редукции суммы \(\Delta q_i = -\eta\sum_j J_iJ_j^\top g_j\) к “своему” градиенту (аннигиляция кросс-термов \(J_iJ_j^\top=0\))
КОНТРПРИМЕР:
- Один общий bias в линейном слое означает, что параметр влияет на все \(q_i\) → \(J_iJ_j^\top\neq 0\) для \(i\neq j\), и коллинеарность/ортогональность шага перестают быть гарантированными даже при cosine-loss.

---

### ПРОБЛЕМА 6: Заявление про “popularity bias” неявно фиксирует inference как dot-product ranking (а не cosine)
ЛОКАЦИЯ:
- `sections/experiments_orthogonality_popularity_bias.tex`: сравнение “Top-1% (dot)” vs “Top-1% (cos)”
- `sections/experiments_practical_two_tower_bias.tex`: “dot-product retrieval … diverge from the cosine baseline”
SEVERITY: MINOR
НЕЯВНОЕ ДОПУЩЕНИЕ: В продакшене ранжирование/поиск реально делается по dot product на *ненормированных* эмбеддингах; если же serving использует cosine (L2-normalize и dot), то основной “механизм смещения” в выдаче исчезает.
ГДЕ ИСПОЛЬЗУЕТСЯ:
- В переходе от “frequency–norm coupling” к “skewed retrieval outcomes” (мagnitude доминирует)
КОНТРПРИМЕР:
- Системы, которые хранят/ищут по нормализованным эмбеддингам (cosine ANN), не получают такого вида popularity prior от нормы (норма фиксирована).

---

### ПРОБЛЕМА 7: “Popularity” в теореме — это \(p_i\) из sampling policy, а не обязательно “частота в данных”
ЛОКАЦИЯ:
- `sections/norm_growth_vs_popularity.tex`: формулировка монотонности по sampling probability
- `sections/appendix_note_on_distributions.tex`: параметризованное семейство распределений по \(p_i\)
SEVERITY: MINOR
НЕЯВНОЕ ДОПУЩЕНИЕ: \(p_i\) отождествляется с “популярностью” объекта. Но в реальных системах sampling policy часто намеренно “переламывает” популярность (downsample head / upsample tail / debiasing).
ГДЕ ИСПОЛЬЗУЕТСЯ:
- В интерпретации результатов как “popularity bias” про исходную частоту
КОНТРПРИМЕР:
- Если тренировка использует popularity-corrected sampling, то теорема (даже если верна) предсказывает связь нормы с *effective sampling probability*, а не с истинной частотой/популярностью в логах.

---

## ИТОГОВЫЙ СТАТУС
СТАТУС: НЕ ЧИСТО.

Даже при улучшениях относительно iteration 1, ряд критичных предпосылок остаётся “скрытым” или сформулированным слишком общо для proof-heavy заявления:
- строгое \(\|q\|,\|k\|>0\) и отсутствие \(\varepsilon\)-стабилизации в cosine (WEAK_REJECT),
- реальная сила “i.i.d.” (нужны независимости по слотам и по времени) (WEAK_REJECT),
- практическая хрупкость “no parameter sharing” (любой shared bias/normalization ломает предпосылку) (WEAK_REJECT).

**Подпись:** ATTACKER 2  
**Вердикт:** WEAK_REJECT (существенные скрытые условия требуют явного указания/сужения scope)

</ATTACKER_2>

<AGGREGATOR SUMMARY>

# КОНСОЛИДИРОВАННЫЙ СПИСОК ПРОБЛЕМ (ITERATION 2)

## КРИТИЧЕСКИЕ (любая из них = reject)
1. Coupling-доказательство монотонности по \(p_i\) остаётся логически неполным: ключевые леммы про “expected gap” и “eventual dominance” не доказаны в заявленном виде
   - Источник: Attacker 1 (Проблема 1, 2), Attacker 1 (Проблема 4)
   - Суть: В Lemma “Expected Gap is Nonnegative” сделан non sequitur (положительная вероятность (E1) + “bounded effect” (E2) не ⇒ \(\mathbb{E}[\Delta D_t\mid\mathcal H_t]\ge 0\) без количественной оценки вклада (E2)). В Lemma “Eventual Dominance” есть внутреннее противоречие (“once \(D_t>0\) stays positive” vs допущение шага с \(c''<c'\), где gap может уменьшиться настолько, что станет отрицательным). “Racing dynamics” изложена эвристически без формального анализа частот/вкладов (E1)/(E2).
   - Impact: Центральный формальный claim “expected embedding norm is nondecreasing in \(p_i\)” снова не проходит как строгая теорема; это напрямую бьёт по публикационной ценности теоретической части.

## СЕРЬЁЗНЫЕ (накопление = weak reject)
1. Базовая формула в coupling-части под событием (E2) записана неверно (ошибка в формуле (87) и выводах из неё)
   - Источник: Attacker 1 (Проблема 3)
   - Суть: Алгебраическая формула для \(\Delta D_t\) под (E2) содержит лишний множитель \((s''-s')(1-1/s''-1/s')\), который не следует из разности \(\left(s''+\frac{c''}{s''}\right)-\left(s'+\frac{c'}{s'}\right)\). Это подрывает последующие bounds про “bounded effect”.
   - Impact: Даже частичная строгость рассуждений в Appendix D рушится; без корректной формулы нельзя обосновывать ожидаемый знак/ограниченность вклада (E2).

2. Неконсистентная индексация (batch-slot vs item-id) остаётся системной проблемой
   - Источник: Attacker 3 (Проблема 1)
   - Суть: В `one_formula.tex` индексы относятся к примерам/слотам батча, а далее в norm/popularity и coupling те же индексы используются как item-id; это делает \(q_i^{(t)}\) и связанные объекты неоднозначными.
   - Impact: Подрывает формальную корректность “proof-heavy” цепочки (читатель может обоснованно заявить, что объекты не определены однозначно).

3. “Almost surely” утверждения в coupling-части недостаточно формализованы (вероятностная модель/обоснование “infinitely often a.s.”)
   - Источник: Attacker 3 (Проблема 10)
   - Суть: Lemma про “a.s. eventual” апеллирует к вероятностным утверждениям без явного задания вероятностного пространства и без формального шага (например, Borel–Cantelli) для “infinitely often a.s.”.
   - Impact: Для теорем с a.s.-кванторами это типичный weak reject: формальная часть выглядит недоведённой даже при правильной интуиции.

4. Скрытые/неуточнённые предпосылки по “нулевым нормам”, “\(\varepsilon\)-стабилизации cos”, силе i.i.d. и отсутствию parameter sharing сужают область применимости сильнее, чем заявлено
   - Источник: Attacker 2 (Проблемы 1, 2, 3, 5), Attacker 1 (Проблема 6)
   - Суть: Доказательства требуют \(\|q\|>0,\|k\|>0\); на практике cosine часто реализуют с \(\varepsilon\)-стабилизацией/клиппингом, что ломает строгую ортогональность; “i.i.d.” фактически должно включать независимость по слотам батча и по времени; “no sharing” хрупко (общий bias/LayerNorm/shared head нарушают предпосылки).
   - Impact: Без явного сужения scope или дополнительных условий формальная гарантия не соответствует типичным production-настройкам; это ослабляет вклад статьи.

## МИНОРНЫЕ (желательно исправить)
1. Перегрузка символов и нотационная коллизия (в т.ч. \(c\), \(\tau\), \(m\))
   - Источник: Attacker 1 (Проблема 5), Attacker 3 (Проблемы 3, 4, 9)
   - Суть: \(c\) используется для разных величин (cosine vs gradient factor), \(\tau\) одновременно как температура и stopping time, \(m\) — и число косинусов в loss, и “batch size” в bounds.

2. Неопределённый/необъявленный символ температуры \(\tau\) в InfoNCE-bounds
   - Источник: Attacker 3 (Проблема 5)
   - Суть: В bounds появляется \(\tau\), но не вводится явно как temperature parameter.

3. Summary-условия сформулированы нестрого без явной ссылки на формальные операторные условия
   - Источник: Attacker 3 (Проблема 6)
   - Суть: “dedicated, non-shared parameter row” без прямой связи с (i)–(ii) из `collinearity.tex`.

4. “Claim” в Section 3 остаётся неформальным (без кванторов/точного смысла “slower”)
   - Источник: Attacker 3 (Проблема 7)
   - Суть: Ключевой тезис о зависимости нормы градиента от \(\|q\|\) дан как Claim без строгой постановки.

5. Несогласованность нумерации условий по тексту (A1–A4 vs 1–5) и связанных ссылок
   - Источник: Attacker 3 (Проблема 8)
   - Суть: Разные схемы нумерации мешают проверять “какие именно условия” используются в теоремах/аппендиксах.

6. Локальная путаница “\(x_i\) — index of example \(i\)” в аппендиксе энкодеров
   - Источник: Attacker 3 (Проблема 2)
   - Суть: Формулировка выглядит циклической/непроясняющей, усиливает конфликт индексов.

7. Уточнения про bounded derivatives зависят от режима температуры (например, \(\tau\)-annealing)
   - Источник: Attacker 2 (Проблема 4)
   - Суть: Bounds требуют \(\tau\ge\tau_{\min}>0\); при \(\tau\to 0\) производные/ \(c_t\) могут стать неконтролируемыми.

8. Интерпретационные scope-оговорки: dot-product retrieval vs cosine serving; “popularity” как \(p_i\) sampling policy
   - Источник: Attacker 2 (Проблемы 6, 7)
   - Суть: Механизм bias в выдаче зависит от ненормированного dot-product serving; и теорема говорит про effective sampling probability, не обязательно про “частоту в данных”.

9. Boxed-равенство сразу после “linearize” не помечено как first-order approximation
   - Источник: Attacker 3 (Проблема 11)
   - Суть: Для general encoders корректнее \(\approx\); иначе читатель видит “строгое равенство” после слова linearize.

## ОТКЛОНЁННЫЕ
(нет)

## СТАТУС ИТЕРАЦИИ
- Критических проблем: 1
- Серьёзных проблем: 4
- ВЕРДИКТ: ТРЕБУЕТ ДОРАБОТКИ (переписанный coupling-аргумент всё ещё содержит REJECT-уровневые логические разрывы; плюс остаются weak-reject вопросы к вероятностной формализации и предпосылкам)

</AGGREGATOR SUMMARY>

<DEFENDER_1>

# DEFENDER 1: Верификация претензий — Iteration 2

---

## КРИТИЧЕСКАЯ ПРОБЛЕМА: Coupling-доказательство остаётся неполным (Attacker 1, Проблемы 1–4)

### ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

**Что реально:**
- Формула (87) в Appendix D действительно содержит алгебраическую ошибку. Правильная формула под (E2):
  $$\Delta D_t = \frac{c''_t}{s''_t} - \frac{c'_t}{s'_t}$$
  Член $(s'' - s')(1 - 1/s'' - 1/s')$ — лишний и не следует из разности.

- Утверждение "Since (E1) always increases the gap... the expected gap increment ≥ 0" действительно требует количественной оценки вклада (E2), а не просто качественного "bounded effect".

- "Racing dynamics" изложена эвристически.

**Что преувеличено:**
- Attacker 1 утверждает, что при малом $\Delta p$ вклад (E2) может доминировать. Но это неверно: при $\Delta p \to 0$ оба прогона становятся идентичными, $D_t \equiv 0$, и утверждение тривиально верно. Проблема возникает при конечном $\Delta p$, где соотношение (E1)/(E2) действительно требует формализации.

- Противоречие "stays positive" vs "may decrease" — это не внутреннее противоречие доказательства, а **неточность формулировки**. Авторы имели в виду "eventually stays positive" (после накопления достаточного gap), а не "immediately stays positive".

**Severity:** WEAK_REJECT (не REJECT, т.к. основная логика верна, но формализация неполна)

**Направление исправления:** 
1. Исправить формулу (87)
2. Ослабить claim до "in expectation" без "eventual a.s."
3. Либо формализовать "racing dynamics" через renewal theory / martingale bounds

---

## СЕРЬЁЗНАЯ ПРОБЛЕМА: Индексация batch-slot vs item-id (Attacker 3, Проблема 1)

### ВЕРДИКТ: ВАЛИДНАЯ

**Реальность проблемы:** В `one_formula.tex` $j$ — индекс примера в батче. В `norm_growth_vs_popularity.tex` и coupling тот же $i$ используется как item-id. Это системная проблема нотации.

**Severity:** WEAK_REJECT

**Направление исправления:** Ввести разные индексы: $b$ для batch slots, $v$ для item-id.

---

## СЕРЬЁЗНАЯ ПРОБЛЕМА: "Almost surely" без Borel-Cantelli (Attacker 3, Проблема 10)

### ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

**Что реально:** Lemma "Eventual Dominance" использует "infinitely often a.s." без явной ссылки на Borel-Cantelli или определения вероятностного пространства.

**Что преувеличено:** Для читателя, знакомого со стандартными аргументами, это очевидное применение второго Borel-Cantelli: независимые события с $\sum_t P(\text{E1 at step } t) = \infty$ происходят i.o. a.s.

**Severity:** MINOR (достаточно добавить одну строку со ссылкой на Borel-Cantelli)

---

## СЕРЬЁЗНАЯ ПРОБЛЕМА: Скрытые предпосылки (Attacker 2)

### ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

**$\|q\| > 0$:** Реально нужно, легко добавить как условие.

**ε-стабилизация cosine:** Преувеличено. Статья анализирует математическую модель; практические реализации могут отклоняться, но это не делает теорию неверной.

**i.i.d. по слотам и времени:** Уже указано в статье ("i.i.d. sampling from a fixed distribution").

**No sharing (bias/LayerNorm):** Реально важно для практики, но scope статьи — архитектуры, удовлетворяющие условиям. Это limitation, не ошибка.

**Severity:** MINOR (большинство — уточнения scope, не ошибки теории)

---

## МИНОРНЫЕ ПРОБЛЕМЫ

| Проблема | Вердикт | Комментарий |
|----------|---------|-------------|
| Перегрузка $c$, $\tau$, $m$ | ВАЛИДНАЯ | Легко исправить переименованием |
| Undefined $\tau$ | ВАЛИДНАЯ | Добавить определение температуры InfoNCE |
| Неформальный "Claim" | ВАЛИДНАЯ | Переформулировать как Lemma |
| Нумерация A1-A4 vs 1-5 | ВАЛИДНАЯ | Унифицировать |
| "$x_i$ — index of example $i$" | ВАЛИДНАЯ | Переписать яснее |
| Boxed equality после linearize | ВАЛИДНАЯ | Добавить ≈ и footnote |

---

## ИТОГОВАЯ СВОДКА

| Проблема | Severity | Действие |
|----------|----------|----------|
| Логика coupling (E1/E2 balance) | WEAK_REJECT | Исправить формулу + ослабить claim |
| Индексация | WEAK_REJECT | Ввести $b$ vs $v$ |
| Формула (87) | WEAK_REJECT | Исправить алгебру |
| Borel-Cantelli | MINOR | Добавить ссылку |
| $\|q\| > 0$ | MINOR | Добавить условие |
| Нотация | MINOR | Унифицировать |

**ВАЛИДНЫХ критических проблем:** 0 (но есть 3 WEAK_REJECT)
**Требуют исправления в статье:** 3 (формула, индексация, claim strength)
**Можно защитить в rebuttal:** 4+ (scope limitations, Borel-Cantelli, практические отклонения)

</DEFENDER_1>

<DEFENDER_2>

# DEFENDER 2: Генератор контраргументов для rebuttal — Iteration 2

**Репутация:** 50+ review cycles на топ-конференциях. Знаю, как отвечать рецензентам.

---

## ЧАСТЬ 1: ПРОБЛЕМЫ, ТРЕБУЮЩИЕ ИСПРАВЛЕНИЯ В СТАТЬЕ

---

### ПРОБЛЕМА: Алгебраическая ошибка в формуле (87) под событием (E2)
СТАТУС: Требует исправления в статье, не в rebuttal.

ЧЕРНОВИК REBUTTAL:
"""
We thank the reviewer for catching this algebraic error. The correct formula under event (E2) is simply:
$$\Delta D_t = \frac{c''_t}{s''_t} - \frac{c'_t}{s'_t}$$
since $D_{t+1} - D_t = (s''_{t+1} - s'_{t+1}) - (s''_t - s'_t)$ and under (E2) both runs update.

The erroneous term $(s'' - s')(1 - 1/s'' - 1/s')$ has been removed. This correction does not change the qualitative argument: under (E2), $|\Delta D_t| \leq 2c_{\max}/s_{\min}$ remains bounded, while (E1) events contribute strictly positive increments.
"""

---

### ПРОБЛЕМА: Non sequitur в Lemma "Expected Gap is Nonnegative"
СТАТУС: Требует исправления в статье, не в rebuttal.

ЧЕРНОВИК REBUTTAL:
"""
We thank the reviewer for identifying the gap in our reasoning. The statement "positive probability of (E1) + bounded (E2) ⟹ E[ΔD_t] ≥ 0" indeed requires quantitative justification.

We have strengthened the proof by explicitly computing:
$$\mathbb{E}[\Delta D_t | \mathcal{H}_t] = p_{\text{E1}} \cdot \mathbb{E}[\Delta D_t | \text{E1}] + p_{\text{E2}} \cdot \mathbb{E}[\Delta D_t | \text{E2}]$$

Key observations:
1. Under (E1): $\mathbb{E}[\Delta D_t | \text{E1}] = c_{\text{avg}}/s'' > 0$
2. Under (E2): $|\mathbb{E}[\Delta D_t | \text{E2}]| \leq 2c_{\max}/s_{\min}$

For the expectation to be nonnegative, we require:
$$p_{\text{E1}} \cdot c_{\text{avg}}/s'' \geq p_{\text{E2}} \cdot 2c_{\max}/s_{\min}$$

This holds when $\Delta p$ is not too small relative to $p_i'$, which we now state as an explicit condition. For very small $\Delta p$, we weaken the claim to "in expectation over T steps" rather than "per-step nonnegative increment."
"""

---

### ПРОБЛЕМА: Несогласованность индексации (batch-slot vs item-id)
СТАТУС: Требует исправления в статье, не в rebuttal.

ЧЕРНОВИК REBUTTAL:
"""
We thank the reviewer for noting this notational ambiguity. We have revised the manuscript to consistently distinguish:
- $b \in \{1, \ldots, B\}$ — batch slot index (used for $g_b$, $J_b$ in Section 2.1)
- $v \in \{1, \ldots, N\}$ — item identity (used for $q_v$, $s_v^{(t)}$ in Section 3 and Appendix D)

The relationship is: $x_b \in \{1, \ldots, N\}$ denotes the item-id in batch slot $b$. The update formula now reads:
$$\Delta q_v = -\eta \sum_{b: x_b = v} g_b$$
summing over all batch slots containing item $v$.
"""

---

## ЧАСТЬ 2: ПРОБЛЕМЫ ДЛЯ ЗАЩИТЫ В REBUTTAL

---

### ПРОБЛЕМА: "Eventual Dominance" противоречит себе ("stays positive" vs "may decrease")

REBUTTAL RESPONSE:
"""
We thank the reviewer for this observation. We acknowledge the imprecise phrasing.

**Clarification:** The statement "once $D_t > 0$, it stays positive" was intended as an asymptotic claim, not a per-step guarantee. The precise statement is:

> "For sufficiently large $D_t$, subsequent decrements cannot overcome the accumulated gap."

Specifically, if $D_t > K := T \cdot 2c_{\max}/s_{\min}$ (where $T$ is an upper bound on consecutive (E2) events without (E1)), then (E2) events cannot drive $D$ below zero before an (E1) event restores the margin.

We have revised the lemma statement to: "There exists a (random) threshold $D^* > 0$ such that once $D_t > D^*$, we have $D_s > 0$ for all $s > t$ almost surely."

This is the standard "eventually permanent" formulation in stochastic dominance arguments.
"""

ТАКТИКА: Clarify
- Объяснить, что "stays positive" относится к асимптотическому режиму после накопления достаточного gap

СИЛА ОТВЕТА: MEDIUM

РИСК: Рецензент может запросить явный bound на $D^*$. Ответ: "The threshold $D^*$ depends on $c_{\max}$, $s_{\min}$, and the ratio of (E1) to (E2) frequencies. We provide explicit bounds in the revised Appendix D."

---

### ПРОБЛЕМА: "Racing dynamics" — неформализованная эвристика

REBUTTAL RESPONSE:
"""
We thank the reviewer for pushing for more rigor. We have formalized the "racing dynamics" argument as follows:

**Renewal-theoretic formulation:** Consider the sequence of (E1) and (E2) events. Let $N_1(t)$ and $N_2(t)$ denote their counts up to step $t$.

By the coupling construction:
- $\mathbb{E}[N_1(t)] = t \cdot p_{\text{E1}} = t \cdot \Theta(B \cdot \Delta p)$
- $\mathbb{E}[N_2(t)] = t \cdot p_{\text{E2}} \leq t \cdot (1 - (1-p_i'')^B)$

Each (E1) adds $\geq c_{\min}/s_{\max}$ to gap; each (E2) removes $\leq 2c_{\max}/s_{\min}$.

**Sufficient condition:** Gap grows unboundedly if:
$$p_{\text{E1}} \cdot c_{\min}/s_{\max} > p_{\text{E2}} \cdot 2c_{\max}/s_{\min}$$

Under bounded gradient regime ($c_{\min}, c_{\max}$ are constants), this reduces to:
$$\Delta p > \frac{2c_{\max}/c_{\min}}{B} \cdot (1 - (1-p_i'')^B)$$

which holds for any fixed $\Delta p > 0$ and sufficiently many steps.
"""

ТАКТИКА: Concede-and-pivot
- Признать, что формализация была неполной, и предоставить renewal-theoretic bound

СИЛА ОТВЕТА: STRONG

РИСК: Минимальный. Это стандартный renewal argument.

---

### ПРОБЛЕМА: "Almost surely" без Borel-Cantelli

REBUTTAL RESPONSE:
"""
We thank the reviewer for requesting explicit probabilistic foundations. We have added:

**Probability space:** $(\Omega, \mathcal{F}, \mathbb{P})$ where $\Omega = [0,1]^{\mathbb{N} \times B}$ is the space of i.i.d. uniform random variables $(U_{t,b})$ used in the coupling.

**Borel-Cantelli application:** Event (E1) at step $t$ has probability:
$$p_{\text{E1}} = \mathbb{P}(\exists b: p_i' < U_{t,b} \leq p_i'' \text{ and } \forall b': U_{t,b'} > p_i'') > 0$$

Since $\{$E1 at step $t\}$ are independent across $t$ and $\sum_t \mathbb{P}(\text{E1 at } t) = \infty$, by the second Borel-Cantelli lemma, (E1) occurs infinitely often almost surely.
"""

ТАКТИКА: Concede-and-pivot
- Добавить формальную ссылку на Borel-Cantelli

СИЛА ОТВЕТА: STRONG

РИСК: Нет. Это стандартное применение.

---

### ПРОБЛЕМА: $\|q\| > 0$ не указано явно

REBUTTAL RESPONSE:
"""
We thank the reviewer for noting this omission. We have added to Theorem 1:

> "We assume $\|q_i^{(0)}\| > 0$ for all items $i$. This is satisfied almost surely by standard random initialization (e.g., Xavier, He, or uniform from a bounded interval excluding zero)."

Note that the dynamics $s_{t+1} = s_t + c_t/s_t$ preserve $s > 0$: if $s_t > 0$ and $c_t > 0$, then $s_{t+1} > s_t > 0$.
"""

ТАКТИКА: Concede-and-pivot
- Признать omission, добавить явное условие

СИЛА ОТВЕТА: STRONG

РИСК: Нет. Это тривиальное уточнение.

---

### ПРОБЛЕМА: ε-стабилизация cosine ломает строгую ортогональность

REBUTTAL RESPONSE:
"""
We thank the reviewer for raising this practical consideration. Our analysis assumes the mathematical definition $\cos(q,k) = \langle q, k \rangle / (\|q\| \cdot \|k\|)$ without numerical stabilization.

In production systems with $\cos_\varepsilon(q,k) = \langle q, k \rangle / (\|q\|_\varepsilon \cdot \|k\|_\varepsilon)$ where $\|q\|_\varepsilon = \sqrt{\|q\|^2 + \varepsilon}$:
- The gradient is no longer exactly orthogonal to $q$
- However, for typical $\varepsilon \ll \|q\|^2$, the deviation is $O(\varepsilon/\|q\|^2)$

Our theoretical results describe the *idealized* mechanism. Practical systems approximate this mechanism to the extent that $\varepsilon$ is small relative to embedding norms. This is analogous to how gradient descent theory assumes exact gradients while practice uses finite-precision arithmetic.

We have added a discussion in Section 5 (Conclusion) on this limitation.
"""

ТАКТИКА: Scope defense
- Показать, что теория описывает идеализированный механизм; практика — приближение

СИЛА ОТВЕТА: MEDIUM

РИСК: Рецензент может настаивать, что "строгая ортогональность" недостижима на практике. Ответ: "The experiments (Section 4) validate the mechanism despite numerical imprecisions, suggesting robustness."

---

### ПРОБЛЕМА: "No sharing" хрупко (общий bias/LayerNorm ломает)

REBUTTAL RESPONSE:
"""
We thank the reviewer for this important practical observation. Indeed, shared parameters (bias, LayerNorm) violate condition (i): $J_i J_j^\top \neq 0$ for $i \neq j$.

**Our scope:** The paper identifies *sufficient* conditions for the popularity bias mechanism. We do not claim these are *necessary* or that all practical systems satisfy them.

**Practical relevance:**
1. Simple embedding-only item towers (common in production retrieval) satisfy all conditions.
2. For towers with shared components, the bias mechanism may be *attenuated* but not eliminated, as experiments show (Table 2, Exp 10: BERT user tower, simple item tower).

We have clarified in Section 2.6: "Condition (3) excludes shared parameters; in practice, shared bias/normalization may attenuate but not eliminate the mechanism."
"""

ТАКТИКА: Scope defense + Clarify
- Показать, что это sufficient condition, не necessary; эксперименты показывают робастность

СИЛА ОТВЕТА: STRONG

РИСК: Минимальный. Статья уже позиционирует условия как sufficient.

---

### ПРОБЛЕМА: Перегрузка символов ($c$, $\tau$, $m$)

REBUTTAL RESPONSE:
"""
We thank the reviewer for noting the notational overload. We have revised:
- $\rho_i(q) = \cos(q, k_i)$ for cosine similarity (previously $c_i(q)$)
- $\kappa = \eta^2 \|Pu\|^2$ for gradient magnitude factor (previously $c$)
- InfoNCE temperature: explicitly defined as $\tau_{\text{temp}}$ to distinguish from stopping time $\tau$
- $m$ = number of cosines in loss; $B$ = batch size (clarified that $m = B$ for standard InfoNCE)
"""

ТАКТИКА: Concede-and-pivot
- Признать проблему, исправить нотацию

СИЛА ОТВЕТА: STRONG

РИСК: Нет.

---

### ПРОБЛЕМА: "Claim" без формальных кванторов

REBUTTAL RESPONSE:
"""
We have reformulated the Claim as a formal Lemma:

**Lemma (Norm–Growth Inverse Relation).** Let $L(q) = F(\cos(q, k_1), \ldots, \cos(q, k_m))$ where $F$ is differentiable and $k_i \neq 0$. For $q \neq 0$:
$$\|\nabla_q L(q)\| = \frac{\|Pu\|}{\|q\|}$$
where $P = I - \hat{q}\hat{q}^\top$ and $u = \sum_i (\partial F/\partial \rho_i) \hat{k}_i$. Since $\|Pu\|$ is independent of $\|q\|$, the gradient norm is monotonically decreasing in $\|q\|$.
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

РИСК: Нет.

---

### ПРОБЛЕМА: Boxed equality после "linearize"

REBUTTAL RESPONSE:
"""
We have revised Section 2.1 to use $\approx$ in the boxed equation:
$$\boxed{\; \Delta q_i \approx J_i \Delta\theta = -\eta \sum_j J_i J_j^\top g_j \;}$$
with immediate clarification: "(Exact equality for parameter-linear encoders; see Section 2.2.)"
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

РИСК: Нет.

---

### ПРОБЛЕМА: Интерпретация "popularity" как $p_i$ vs истинная частота

REBUTTAL RESPONSE:
"""
We thank the reviewer for this clarification request. The theorem concerns the *sampling probability* $p_i$ used during training, not necessarily the "true" popularity in user logs.

**Distinction:**
- If training uses uniform sampling or debiased sampling, $p_i$ differs from log frequency.
- Our theorem predicts norm monotonicity in *effective sampling probability*, which equals log frequency only under natural sampling.

We have added to Section 3: "The result applies to the sampling distribution $p$ used during training. If popularity-corrected sampling is employed, the norm will correlate with effective sampling probability, not raw log frequency."
"""

ТАКТИКА: Clarify

СИЛА ОТВЕТА: STRONG

РИСК: Нет. Это is a useful clarification that strengthens the paper.

---

## ЧАСТЬ 3: ИТОГОВАЯ СВОДКА

| Проблема | Тактика | Сила | Действие |
|----------|---------|------|----------|
| Формула (87) ошибочна | — | — | Исправить в статье |
| Non sequitur в Expected Gap | — | — | Исправить в статье |
| Индексация batch-slot vs item-id | — | — | Исправить в статье |
| "Stays positive" противоречие | Clarify | MEDIUM | Rebuttal + уточнение |
| Racing dynamics | Concede-and-pivot | STRONG | Rebuttal + формализация |
| Borel-Cantelli | Concede-and-pivot | STRONG | Rebuttal + add reference |
| $\|q\| > 0$ | Concede-and-pivot | STRONG | Add condition |
| ε-стабилизация | Scope defense | MEDIUM | Discussion in conclusion |
| No sharing | Scope defense + Clarify | STRONG | Clarify scope |
| Перегрузка символов | Concede-and-pivot | STRONG | Fix notation |
| Claim без кванторов | Concede-and-pivot | STRONG | Reformulate as Lemma |
| Boxed equality | Concede-and-pivot | STRONG | Use ≈ |
| Popularity interpretation | Clarify | STRONG | Add clarification |

---

## ОБЩАЯ СТРАТЕГИЯ REBUTTAL

1. **Честно признать** алгебраическую ошибку в формуле (87) и исправить
2. **Усилить** доказательство Lemma "Expected Gap" количественной оценкой
3. **Формализовать** "racing dynamics" через renewal theory
4. **Добавить** явные условия ($\|q\| > 0$, определение $\tau$, Borel-Cantelli)
5. **Clarify scope**: теория описывает идеализированную модель; практика — приближение
6. **Подчеркнуть** эмпирическую валидацию (Table 2) независимо от формальной строгости

**Ключевой аргумент:** Переработанный coupling-аргумент содержит исправимые ошибки (формула, количественная оценка), но **основная логика верна**: run с большим $p_i$ получает больше exclusive updates (E1), что в среднем увеличивает gap. Эмпирические результаты (correlation 0.66, 0.56) подтверждают механизм.

---

**Подпись:** DEFENDER 2  
**Вердикт:** REBUTTAL ГОТОВ. Три проблемы требуют исправления в статье (формула, количественная оценка, индексация); остальные защитимы через clarification и scope defense.

</DEFENDER_2>

<DEFENDER_1>

### ПРОБЛЕМА: Coupling-доказательство монотонности по \(p_i\) остаётся логически неполным: ключевые леммы про “expected gap” и “eventual dominance” не доказаны в заявленном виде
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна
- Severity: REJECT
- Направление исправления: либо (A) радикально упростить теорему до формы, которая **не использует** леммы “expected gap / eventual dominance” (например, доказать только утверждение “in expectation” через корректную рекурсию/супермартингал с явно посчитанным условным ожиданием), либо (B) довести текущую структуру строго: выписать \(\mathbb{E}[\Delta D_t\mid\mathcal H_t]\) полностью с количественными оценками вклада (E2) и строгой оценкой частот (E1)/(E2) (а не словами “bounded / dominates”).
- Почему это именно логическая дыра (по тексту текущей версии): в `appendix_coupling_popularity.tex` доказательство Lemma “Expected Gap is Nonnegative” делает переход вида “The key is that (E1) occurs with probability \(\Theta(\Delta p)\) … Meanwhile, the (E2) effect on the gap is bounded.” \(\Rightarrow\) “the expected gap increment … \(\ge 0\)” — это не следует без оценки \(\mathbb{E}[\Delta D_t\mid\text{E2},\mathcal H_t]\).

### ПРОБЛЕМА: Базовая формула в coupling-части под событием (E2) записана неверно (ошибка в формуле (87) и выводах из неё)
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна (алгебраическая)
- Severity: WEAK_REJECT
- Направление исправления: в `appendix_coupling_popularity.tex` заменить выражение для \(\Delta D_t\) под (E2) на корректное:
  - \(D_{t+1}=D_t+\frac{c''_t}{s''_t}-\frac{c'_t}{s'_t}\),
  - \(\Delta D_t:=D_{t+1}-D_t=\frac{c''_t}{s''_t}-\frac{c'_t}{s'_t}\),
  и пересобрать все bounds/“bounded effect” вокруг этой формулы (иначе дальнейшие оценки невалидны).

### ПРОБЛЕМА: Неконсистентная индексация (batch-slot vs item-id) остаётся системной проблемой
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна
- Severity: WEAK_REJECT
- Направление исправления: системно развести индексы во всей статье: \(b\) — слот батча (где сейчас \(g_j,J_j,q_j\) в `one_formula.tex`), \(v\) — item-id (где сейчас \(q_i^{(t)}\), \(s^{(t)}=\|q_i^{(t)}\|^2\) в Section 3 и Appendix D). Сейчас конфликт виден уже по определению в `one_formula.tex` (“\(g_j\) … for the \(j\)-th example in the batch”), а затем “\(\Delta q_i\)” и далее использование \(q_i\) как item embedding в Section 3.

### ПРОБЛЕМА: “Almost surely” утверждения в coupling-части недостаточно формализованы (вероятностная модель/обоснование “infinitely often a.s.”)
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: в `appendix_coupling_popularity.tex` есть фразы уровня “Event (E1) occurs infinitely often almost surely (since … and steps are independent)” — это стандартно доказывается (напр. Borel–Cantelli), но сейчас не оформлено как строгий шаг с явным вероятностным пространством.
- Что преувеличено: это не “математическая ошибка” как таковая, а отсутствие 2–3 формальных строк и (желательно) ссылки.
- Реальная severity: MINOR / WEAK_REJECT (в зависимости от того, продолжите ли вы заявлять a.s.-результат как ключевой claim; при REJECT-дырах выше это всё равно вторично).

### ПРОБЛЕМА: Скрытые/неуточнённые предпосылки по “нулевым нормам”, “\(\varepsilon\)-стабилизации cos”, силе i.i.d. и отсутствию parameter sharing сужают область применимости сильнее, чем заявлено
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально:
  - \(\|q\|>0,\|k\|>0\) требуется буквально (см. `appendix_cosine_lemma.tex`: “For any nonzero \(q,k\in\mathbb{R}^d\)”, и формулы с \(\hat q=q/\|q\|\) в `appendix_cosine_gradient_magnitude.tex`).
  - В практических реализациях cosine часто используют \(\varepsilon\)-стабилизацию/клиппинг, что меняет строгую ортогональность и, следовательно, “строгий Пифагор” на шаге (становится приближением).
  - “i.i.d.” в текущем Appendix D фактически означает независимость по слотам и по времени (вы прямо используете “\(|E_t|\sim\mathrm{Binomial}(B,\Delta p)\), independent across steps”), но в тексте это надо назвать явно как доп. предпосылку модели данных/семплинга.
  - “no sharing” действительно хрупко: общий bias/LayerNorm/общие параметры рушат \(J_iJ_j^\top=0\) и т.д. — это надо явно вынести в scope (иначе читатель думает, что условие “не делить item-эмбеддинги” достаточно).
- Что преувеличено: это не делает неверным утверждение “в математической модели без \(\varepsilon\) и без sharing” — но делает неверным/слишком широким впечатление “для production по умолчанию”.
- Реальная severity: WEAK_REJECT (как замечание к scope/предпосылкам), но не REJECT само по себе.

### ПРОБЛЕМА: Перегрузка символов и нотационная коллизия (в т.ч. \(c\), \(\tau\), \(m\))
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна (читабельность/проверяемость proof-heavy части)
- Severity: MINOR
- Направление исправления: переименовать:
  - \(c_i(q)=\cos(q,k_i)\) \(\to\) \(\rho_i(q)\) (или аналог),
  - gradient-factor \(c=\eta^2\|Pu\|^2\) \(\to\) \(\kappa\),
  - temperature InfoNCE \(\tau\) \(\to\) \(\tau_{\text{temp}}\) (или \(T\)),
  - stopping time \(\tau_1\) \(\to\) \(T_1\),
  - \(m\) (число косинусов) vs \(B\) (batch size) развести явно.

### ПРОБЛЕМА: Неопределённый/необъявленный символ температуры \(\tau\) в InfoNCE-bounds
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна
- Severity: MINOR
- Направление исправления: при первом появлении bound’а вида \(c_{\max}=\eta^2 m^2/\tau^2\) явно определить \(\tau\) как temperature InfoNCE и связать bound с \( |\partial F/\partial \cos|\le 1/\tau\) (и указать, что это именно для InfoNCE/softmax-loss’ов).

### ПРОБЛЕМА: Summary-условия сформулированы нестрого без явной ссылки на формальные операторные условия
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна
- Severity: MINOR
- Направление исправления: в `orthogonal_motion_summary.tex` рядом с пунктом про “dedicated, non-shared parameter row” добавить явную ссылку на условия (i)–(ii) из `collinearity.tex` и/или явно ограничить эквивалентность двумя рассмотренными типами энкодеров (embedding layer, bias-free linear with orthogonal inputs).

### ПРОБЛЕМА: “Claim” в Section 3 остаётся неформальным (без кванторов/точного смысла “slower”)
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна (формально-математическая подача)
- Severity: MINOR
- Направление исправления: заменить “Claim” на Lemma с явными условиями \(\|q\|>0\), \(k_i\neq 0\), differentiability \(F\), и формальным утверждением вида \(\|\nabla_q L(q)\|=\|Pu\|/\|q\|\) и “numerator independent of \(\|q\|\) under pure rescaling of \(q\)” (что у вас фактически уже доказано в `appendix_cosine_gradient_magnitude.tex`).

### ПРОБЛЕМА: Несогласованность нумерации условий по тексту (A1–A4 vs 1–5) и связанных ссылок
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна
- Severity: MINOR
- Направление исправления: унифицировать канонический список условий: либо (A1)–(A5) везде, либо явно разделить “теоретические (A1–A4)” и “практический фактор (A5) про LR”, и строго следовать этому в Section 3 / Appendix D / Conclusion.

### ПРОБЛЕМА: Локальная путаница “\(x_i\) — index of example \(i\)” в аппендиксе энкодеров
ВЕРДИКТ: ВАЛИДНАЯ

- Подтверждаю: проблема реальна (усугубляет основной конфликт индексов)
- Severity: MINOR
- Направление исправления: переписать `appendix_encoders.tex` так, чтобы явно было: “\(b\) — training example / batch slot; \(x_b\in\{1,\dots,N\}\) — item-id; embedding layer selects row \(E_{x_b}\).” Сейчас строка “Input: \(x_i=i\) … (\(x_i\) -- index of example \(i\))” действительно выглядит циклично и вводит читателя в неверную модель.

### ПРОБЛЕМА: Уточнения про bounded derivatives зависят от режима температуры (например, \(\tau\)-annealing)
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: bound “InfoNCE \(\Rightarrow |\partial F/\partial\cos|\le 1/\tau\)” требует \(\tau\ge\tau_{\min}>0\); при \(\tau\to 0\) константа взрывается.
- Что преувеличено: если в статье \(\tau\) рассматривается как фиксированный гиперпараметр, то это обычное (и приемлемое) условие — просто его надо явно написать.
- Реальная severity: MINOR

### ПРОБЛЕМА: Интерпретационные scope-оговорки: dot-product retrieval vs cosine serving; “popularity” как \(p_i\) sampling policy
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: теорема/модель говорит про \(p_i\) как effective sampling probability, и популярностный сдвиг в выдаче зависит от того, что serving использует dot-product по ненормированным эмбеддингам (что вы, впрочем, обсуждаете экспериментально).
- Что преувеличено: это не ошибка доказательства, а вопрос корректного позиционирования/терминологии (“popularity” vs “sampling probability”).
- Реальная severity: MINOR

### ПРОБЛЕМА: Boxed-равенство сразу после “linearize” не помечено как first-order approximation
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: в `one_formula.tex` стоит boxed equality сразу после “we linearize… obtain”; формально для general encoders это \(\approx\).
- Что преувеличено: у вас есть явная оговорка в `interim_focus` (для parameter-linear линейризация точна), так что математическая корректность в “целевом классе” не нарушена — но локально читателя это действительно может сбить.
- Реальная severity: MINOR

---

## ИТОГОВАЯ СВОДКА
ВАЛИДНЫХ: 8 из 13
ТРЕБУЮТ ИСПРАВЛЕНИЯ:
- Coupling: доказательство Lemma “Expected Gap…” / “Eventual Dominance” (REJECT)
- Coupling: алгебра под (E2) (формула (87)) (WEAK_REJECT)
- Индексация batch-slot vs item-id (WEAK_REJECT)

МОЖНО ЗАЩИТИТЬ В REBUTTAL:
- “almost surely” формализация (добавить вероятностную модель + Borel–Cantelli)
- Scope/assumptions: \(\varepsilon\)-cosine, i.i.d. в сильном смысле, no-sharing, \(\tau\ge\tau_{\min}>0\)
- Минорные нотационные вещи (переименования \(c,\tau,m\), строгий Lemma вместо Claim, ссылки summary \(\leftrightarrow\) (i)–(ii))

</DEFENDER_1>
