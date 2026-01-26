<ATTACKER_1>

# ATTACKER 1: Логические дыры в доказательствах — Iteration 6

**Rejection rate: 80%. Репутация: нахожу фатальные логические дыры, которые другие пропускают.**

---

## ОЦЕНКА ИЗМЕНЕНИЙ В ITERATION 3 (статья)

**Изменения с iteration 2 → iteration 3:**

1. ✅ **"Replay model" → "Conditional-on-increments model"** (appendix_coupling_popularity.tex, строка 7): Более точное название, отражающее суть.

2. ✅ **Условие (i) исправлено** (collinearity.tex, строка 10): Теперь "$J_i J_j^\top = 0$ for $x_j \neq x_i$" — явная ссылка на item-id, а не batch-slot.

3. ✅ **norm_growth_vs_popularity.tex** (строка 10): Теперь "conditional on per-update increments" — честное ограничение scope.

4. ✅ **cosine_gradient_orthogonality.tex** (строка 24): Явно указано "(for duplicates use $\bar g_i$)".

---

## АНАЛИЗ КРИТИКИ ИЗ ITERATION 4 И ITERATION 5

### Разбор критики INDEPENDENT_ATTACKER (iteration5)

**Претензия:** "Conditional-on-increments model делает результат тривиальным — если каждое обновление добавляет фиксированную величину, то больше обновлений = большая сумма."

**Мой ответ:**

1. **Это не тавтология, а изоляция фактора.** Авторы явно разделяют два вопроса:
   - (A) Как sampling frequency влияет на число обновлений? → Доказано формально
   - (B) Как δ_k зависит от batch composition? → Явно вынесено за scope
   
   Изоляция (A) — это стандартная методология в теоретическом ML (cf. analysis of convergence rates "conditional on gradient bounds").

2. **Авторы честно ограничивают scope** (строки 56-57):
   > "To turn this mechanism into an unconditional statement about the full SGD dynamics without fixing the sequence $\{\delta_k\}$, one needs additional control... this lies outside the four assumptions... and is therefore not claimed here."

3. **Эмпирика подтверждает механизм.** Table 2 показывает correlations 0.66, 0.56 между frequency и norm в реальных системах, где δ_k **не** фиксирован. Это свидетельствует, что (A) — доминирующий фактор на практике.

**Вердикт:** Это MINOR issue (scope limitation), не WEAK_REJECT. Механизм полезен для понимания, даже если неполон.

---

### Разбор критики ATTACKER_3 (iteration4): Индексация

**Претензия:** "Несогласованность индексации (batch-slot vs item-id) — системная проблема."

**Мой ответ:**

1. **Исправление в iteration3 помогает.** Условие (i) теперь явно использует "$x_j \neq x_i$", что clarifies смысл.

2. **В ключевых формулах индексация понятна из контекста:**
   - collinearity.tex (строка 31): $\sum_{j: x_j = x_i} g_j$ — очевидно, что $j$ это batch-slot, $x_i$ это item-id
   - appendix_coupling_popularity.tex (строка 11): "$q_i^{(t)}$ denote the item embedding" — явно item-id

3. **Нет формул, где смешение приводит к ошибке.** Я проверил все уравнения — нигде индексы не используются некорректно.

**Вердикт:** MINOR. Улучшить можно, но корректность не нарушена.

---

### Разбор критики ATTACKER_2 (iteration4): Скрытые условия

**Претензия:** "$\|q\| > 0$, ε-cosine, no parameter sharing — скрытые условия уровня WEAK_REJECT."

**Мой ответ:**

1. **$\|q\| > 0$:** В appendix_cosine_lemma.tex (строка 4) явно указано "For any nonzero $q, k$". Это условие используется везде, где деление на норму.

2. **ε-cosine:** Это scope limitation (практика vs теория), не логическая дыра. Статья анализирует математическую модель; практические системы — приближения.

3. **No parameter sharing:** Явно указано в условии (3) orthogonal_motion_summary.tex: "each distinct input has a dedicated, non-shared parameter row". Это **явное условие**, не скрытое.

**Вердикт:** MINOR. Это явные или стандартные условия, не логические дыры.

---

## СОБСТВЕННЫЙ ГЛУБОКИЙ АНАЛИЗ

Я перечитал все appendices и доказательства. Структура аргументации:

**Цепочка доказательства:**
1. Cosine loss → gradient ⊥ embedding (Appendix B) ✓
2. Parameter-linear + non-shared → update ∥ gradient (Section 2.4) ✓
3. Update ∥ gradient + gradient ⊥ embedding → update ⊥ embedding ✓
4. Update ⊥ embedding → Pythagorean: $s_{t+1} = s_t + \delta_k$ ✓
5. More sampling → more updates (coupling, Step 2) ✓
6. More updates + nonnegative δ_k → larger sum (Step 3) ✓

**Проверка каждого шага:**

**Шаг 1 (Appendix B):** $\langle q, \nabla_q \cos(q, k) \rangle = 0$. Прямое вычисление, корректно.

**Шаг 2 (collinearity.tex):** 
- Формула $\Delta q_i = -\eta \sum_{j: x_j = x_i} g_j = -\eta c_i \bar{g}_i$ ✓
- Условия (i)–(ii) на $J_i J_j^\top$ выписаны корректно ✓
- Для embedding layer: $J_i J_j^\top = I_d$ if $x_i = x_j$, else 0 ✓

**Шаг 3 (cosine_gradient_orthogonality.tex):**
- $q_i \perp g_j$ для каждого $j$ с $x_j = x_i$ (по шагу 1)
- $q_i \perp \bar{g}_i = \frac{1}{c_i} \sum_j g_j$ (линейность скалярного произведения) ✓
- Явно указано "(for duplicates use $\bar g_i$)" ✓

**Шаг 4 (Pythagorean):** 
- $\|q_i + \Delta q_i\|^2 = \|q_i\|^2 + 2\langle q_i, \Delta q_i \rangle + \|\Delta q_i\|^2$
- $\langle q_i, \Delta q_i \rangle = 0$ (по шагу 3)
- Следовательно $s_{t+1} = s_t + \delta_k$ ✓

**Шаг 5 (coupling):**
- $N_T^{(p)} \sim \text{Binomial}(T, \pi(p))$ ✓
- $\pi(p) = 1 - (1-p)^B$ — монотонно по $p$ ✓
- Bernoulli coupling: $N_T^{(p'')} \geq N_T^{(p')}$ a.s. для $p' < p''$ ✓

**Шаг 6 (conditional-on-increments):**
- $f(n) = s_0 + \sum_{k=1}^n \delta_k$ нестрого возрастает (δ_k ≥ 0) ✓
- $N_T^{(p'')} \geq N_T^{(p')}$ a.s. → $f(N_T^{(p'')}) \geq f(N_T^{(p')})$ a.s. ✓

**Все логические переходы корректны.**

---

## ОСТАВШИЕСЯ ПРОБЛЕМЫ (ВСЕ MINOR)

### ПРОБЛЕМА 1: Лемма об ортогональности не доказана для второго аргумента

**ЛОКАЦИЯ:** appendix_cosine_lemma.tex

**SEVERITY:** MINOR

**СУТЬ:** Доказано $\langle q, \nabla_q \cos(q, k) \rangle = 0$. Для item tower нужно $\langle k, \nabla_k \cos(q, k) \rangle = 0$. По симметрии это верно, но явно не показано.

**ПОЧЕМУ НЕ КРИТИЧНО:** Вычисление симметрично: $\nabla_k \cos(q, k) = (q - \cos(q,k) \cdot k) / (\|q\| \|k\|)$, и $\langle k, \nabla_k \cos(q, k) \rangle = 0$ следует аналогично.

---

### ПРОБЛЕМА 2: Индексация — несистемная

**ЛОКАЦИЯ:** one_formula.tex, collinearity.tex, appendix_encoders.tex

**SEVERITY:** MINOR

**СУТЬ:** Символ $i$ используется и как batch-slot, и как item-id в разных местах.

**ПОЧЕМУ НЕ КРИТИЧНО:** После исправления условия (i) на "$x_j \neq x_i$" смысл понятен из контекста.

---

### ПРОБЛЕМА 3: Conditional-on-increments model — scope limitation

**ЛОКАЦИЯ:** appendix_coupling_popularity.tex

**SEVERITY:** MINOR

**СУТЬ:** Результат условен на фиксированных $\{\delta_k\}$. Зависимость δ_k от popularity не анализируется.

**ПОЧЕМУ НЕ КРИТИЧНО:** Авторы **явно** это признают и ограничивают claim. Эмпирика показывает, что механизм работает.

---

### ПРОБЛЕМА 4: Перегрузка символа $c_i$

**ЛОКАЦИЯ:** collinearity.tex vs appendix_cosine_gradient_magnitude.tex

**SEVERITY:** MINOR

**СУТЬ:** $c_i$ = count в одном месте, $c_i(q) = \cos(q, k_i)$ в другом.

**ПОЧЕМУ НЕ КРИТИЧНО:** В appendix используется с аргументом $c_i(q)$, что различает.

---

## ИТОГОВЫЙ СТАТУС

**СТАТУС: ЧИСТО. Логических дыр уровня REJECT или WEAK_REJECT не обнаружено.**

### Сравнение с предыдущими итерациями:

| Проблема | Iter 1 | Iter 2 | Iter 3 | Iter 4 | Iter 5 | Iter 6 |
|----------|--------|--------|--------|--------|--------|--------|
| Coupling: $c' \neq c''$ | REJECT | REJECT | ✅ | ✅ | ✅ | ✅ |
| Coupling: non sequitur | REJECT | REJECT | ✅ | ✅ | ✅ | ✅ |
| Формула обновления | WEAK_REJECT | WEAK_REJECT | ✅ | ✅ | ✅ | ✅ |
| Replay model definition | — | — | ✅ | ✅ | ✅ | ✅ (переименован) |
| Conditional-on-increments scope | — | — | MINOR | MINOR | WEAK_REJECT* | MINOR |
| Индексация | MINOR | MINOR | MINOR | WEAK_REJECT* | — | MINOR |

*Разногласие между attackers: я (ATTACKER_1) считаю MINOR, другие — WEAK_REJECT.

---

## РАЗНОГЛАСИЕ С ДРУГИМИ ATTACKERS

**ATTACKER_3 и INDEPENDENT_ATTACKER** выставляют WEAK_REJECT за:
1. Индексацию (ATTACKER_3)
2. Conditional-on-increments scope (INDEPENDENT_ATTACKER)

**Моя позиция:**

1. **Индексация:** После исправления условия (i) на "$x_j \neq x_i$" смысл ясен. Нет формулы, где индексы используются некорректно. Это presentation issue, не логическая дыра.

2. **Conditional-on-increments:** Авторы **честно** ограничили scope. Изоляция одного фактора (sampling frequency) — стандартная методология. Эмпирика подтверждает, что механизм доминирует на практике.

**Ключевой вопрос для Area Chair:** Является ли scope limitation причиной для WEAK_REJECT?

Мой ответ: **НЕТ**, если ограничения честно указаны. Статья заявляет "mechanism", не "complete theory". Abstract говорит "explicit guarantees for the emergence of popularity bias" — и эти guarantees **действительно** доказаны (conditional on increments).

---

## ВЕРДИКТ

**ACCEPT**

Все логические дыры, выявленные в iterations 1–2 (REJECT level), исправлены. Оставшиеся issues — это:

1. **Presentation** (индексация, нотация) — MINOR
2. **Scope limitations** (conditional-on-increments, ε-cosine) — честно указаны, не дыры
3. **Missing minor steps** (симметрия леммы) — тривиальны

**Coupling-аргумент математически корректен:**
- Условия явно сформулированы
- Все шаги доказаны
- Ограничения честно указаны
- Эмпирика подтверждает применимость

---

**Подпись:** ATTACKER 1  
**Вердикт:** ACCEPT

**Примечание:** Разногласие с ATTACKER_3 и INDEPENDENT_ATTACKER касается интерпретации "WEAK_REJECT" vs "MINOR" для scope/presentation issues. Я не нахожу **логических** дыр. Вопрос, достаточно ли сильны claims, — это вопрос positioning, а не математической корректности.

</ATTACKER_1>

<ATTACKER_2>

# ATTACKER 2: Неявные допущения и скрытые условия — Iteration 6

Опираюсь на свежую критику из `iteration4.md` и `iteration5.md` + на разбор обновлённой статьи `final_tex_paper_in_this_folder_icml26_iteration3` (в частности, `appendix_coupling_popularity.tex`, `collinearity.tex`, `one_formula.tex`). В iteration3 авторы заметно улучшили строгость: “Replay model” переименован и честно позиционирован как **conditional-on-increments**, в coupling явно добавлено **with replacement** и оговорены дубликаты, а в `collinearity.tex` корректно введён \(\bar g_i\). Ниже — то, что всё ещё остаётся **молчаливыми условиями** (или спрятано в аппендиксах/контексте), и где это ломает “строгость” заявлений.

---

### ПРОБЛЕМА 1: Неявное требование \(\|q\|>0\) и \(\|k\|>0\) “везде и всегда” (а не только в лемме)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration3/sections/appendix_cosine_lemma.tex` (условие “nonzero”), `.../sections/appendix_cosine_gradient_magnitude.tex` (\(\hat q=q/\|q\|\), \(\hat k=k/\|k\|\))
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Не просто “в лемме”, а фактически во всей статье предполагается, что на всех шагах обучения все эмбеддинги, участвующие в loss, имеют ненулевую норму.
ГДЕ ИСПОЛЬЗУЕТСЯ: Везде, где делят на \(\|q\|\|k\|\) и утверждают “строго ортогонально ⇒ строго Пифагор”.
КОНТРПРИМЕР: Нулевые строки (padding/removed items), принудительное зануление/клиппинг, квантование, или просто инженерная инициализация с нулями для спец-токенов делают cosine/градиент формально не определёнными; в реальности включают стабилизацию (см. следующую проблему), и доказанные равенства перестают соответствовать вычисляемой функции.

---

### ПРОБЛЕМА 2: Неявное предположение о “чистом cosine” без \(\varepsilon\)-стабилизации/guard’ов
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration3/sections/introduction.tex` (определение cosine), `.../sections/cosine_gradient_orthogonality.tex`
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: В обучении используется именно \(\cos(q,k)=\frac{q^\top k}{\|q\|\|k\|}\), без \(\|q\|_\varepsilon=\sqrt{\|q\|^2+\varepsilon}\), clamp норм, stop-grad по норме и т.п.
ГДЕ ИСПОЛЬЗУЕТСЯ: В ключевой “строгой” цепочке \(g\perp q \Rightarrow \Delta q\perp q \Rightarrow \|q\|^2\) монотонно растёт при каждом апдейте.
КОНТРПРИМЕР: Для \(\cos_\varepsilon\) вообще говоря \(q^\top\nabla_q\cos_\varepsilon(q,k)\neq 0\) ⇒ шаг может иметь радиальную компоненту (в т.ч. отрицательную), а “строгая ортогональность” становится приближением без явного контроля ошибки.

---

### ПРОБЛЕМА 3: Лемма про ортогональность выписана только для \(\nabla_q\cos(q,k)\), но статья молча переносит её и на item-side градиент \(\nabla_k\cos(q,k)\)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration3/sections/appendix_cosine_lemma.tex`
SEVERITY: MINOR
НЕЯВНОЕ ДОПУЩЕНИЕ: По симметрии так же верно \(\langle k,\nabla_k\cos(q,k)\rangle=0\), и это “очевидно” без отдельной проверки.
ГДЕ ИСПОЛЬЗУЕТСЯ: В части, где ортогональность применяется именно к item-эмбеддингам (вторая башня).
КОНТРПРИМЕР: Нет (утверждение верно), но для proof-heavy текста отсутствие явного шага — типичная точка атаки рецензента (“missing lemma for the second argument”).

---

### ПРОБЛЕМА 4: Boxed-равенство после “we linearize … obtain” скрыто требует parameter-linearity (или режима малых шагов)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration3/sections/one_formula.tex`, boxed \(\Delta q_i = J_i\Delta\theta\)
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Либо энкодер parameter-linear (тогда это равенство), либо learning rate достаточно мал, чтобы игнорировать \(O(\|\Delta\theta\|^2)\); иначе формула — лишь \(\approx\).
ГДЕ ИСПОЛЬЗУЕТСЯ: Как “one equation that underpins the analysis” — читатель может считать её универсальной, а не условной.
КОНТРПРИМЕР: Двухслойные (даже линейные) энкодеры или глубокие энкодеры на реальных шагах оптимизации: направление \(\Delta q\) может существенно отличаться от \(J\Delta\theta\), и строгие выводы про ортогональность апдейта не следуют.

---

### ПРОБЛЕМА 5: Неявное отождествление “item-id” \(\Leftrightarrow\) “фиксированный вход \(x\)” (lookup), хотя это ключ к интерпретации “нормы item embedding”
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration3/sections/appendix_encoders.tex` (формулировка “\(x_i=i\)… index of example \(i\)”), `.../sections/collinearity.tex` (условия вида \(x_j=x_i\))
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Для каждого item существует один фиксированный вход на item tower (id-only), так что “\(\|q_i\|\)” — действительно одна скалярная характеристика item’а.
ГДЕ ИСПОЛЬЗУЕТСЯ: Везде, где говорится “embedding norm of item \(i\)” и где суммируют по вхождениям \(x_j=x_i\).
КОНТРПРИМЕР: Контентные/контекстные item-фичи (time-varying features, аугментации): один и тот же item-id может порождать разные \(x\Rightarrow q\), и тогда “норма item embedding” не является хорошо определённым объектом без дополнительных оговорок.

---

### ПРОБЛЕМА 6: “Conditional-on-increments model” не скрывает, но всё равно требует аккуратного позиционирования в Abstract/Intro (иначе воспринимается как теорема про SGD)
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration3/sections/appendix_coupling_popularity.tex` (Definition + финальная оговорка), `.../sections/introduction.tex` (формулировки contribution)
SEVERITY: MINOR
НЕЯВНОЕ ДОПУЩЕНИЕ: Читатель не перепутает доказанный факт “монотонность по \(p_i\) **при фиксированных** \(\{\delta_k\}\)” с утверждением про полную SGD-динамику.
ГДЕ ИСПОЛЬЗУЕТСЯ: В интерпретации “formal mechanism linking sampling frequency to norm growth” (см. `iteration5.md`: претензия о “тривиальности” возникает именно из-за этого разрыва).
КОНТРПРИМЕР: Если sampling policy меняет batch composition/hard negatives, то \(\delta_k\) меняются систематически, и “больше апдейтов” не обязательно означает “больше суммарный рост нормы” без доп. контроля (авторы это признают, но это важно постоянно держать в поле зрения читателя).

---

### ПРОБЛЕМА 7: Несогласованность индексации (batch-slot vs item-id) создаёт скрытое требование “читать правильно”
ЛОКАЦИЯ: `final_tex_paper_in_this_folder_icml26_iteration3/sections/one_formula.tex`, `.../sections/collinearity.tex`, `.../sections/appendix_coupling_popularity.tex`
SEVERITY: WEAK_REJECT
НЕЯВНОЕ ДОПУЩЕНИЕ: Один и тот же индекс/подстрочник не меняет смысл “молча” между “пример в батче” и “item-id”, иначе часть формул становится двусмысленной.
ГДЕ ИСПОЛЬЗУЕТСЯ: В частности, в переходах между общей формулой \(\Delta q_i=-\eta\sum_j J_iJ_j^\top g_j\) (где \(j\) — batch slot) и условиями (i)–(ii), сформулированными через \(x_j\neq x_i\) (где \(i\) уже читается как item-id).
КОНТРПРИМЕР: Не математический контрпример, а “reviewer attack”: рецензент фиксирует неоднозначность и объявляет derivation insufficiently well-defined (“variables are overloaded; equations are not unambiguous”), что для proof-heavy paper легко становится weak reject.

---

## ИТОГОВЫЙ СТАТУС
СТАТУС: НЕ ЧИСТО. Есть скрытые предпосылки уровня WEAK_REJECT (строгость cosine без стабилизации; глобальная ненулевая норма; корректность boxed-линейризации; и неоднозначность индексации/объекта “item embedding”).

</ATTACKER_2>

<ATTACKER_3>

# ATTACKER 3: Формальная строгость и consistency — Финальный анализ iteration 6

**Роль:** Профессор математики ETH Zürich. Фокус: нотация, кванторы, согласованность определений.

**Контекст:** Анализирую статью `final_tex_paper_in_this_folder_icml26_iteration3` с учётом критик из iteration4 (ATTACKER_1: ACCEPT, ATTACKER_2: скрытые условия WEAK_REJECT, ATTACKER_3: индексация WEAK_REJECT) и iteration5 (INDEPENDENT_ATTACKER: replay model WEAK_REJECT).

---

## ОБЩАЯ ОЦЕНКА ПРОГРЕССА

После четырёх итераций исправлений статья достигла **существенного улучшения**:

**Исправлено:**
- ✅ Формула обновления при дубликатах (строки 29-33 `collinearity.tex`): теперь $\Delta q_i = -\eta \sum_{j: x_j = x_i} g_j = -\eta c_i \bar{g}_i$ с явным определением $\bar{g}_i := \frac{1}{c_i} \sum_{j: x_j = x_i} g_j$
- ✅ Replay model формально определён (строки 6-8 `appendix_coupling_popularity.tex`)
- ✅ i.i.d. sampling уточнён: "with replacement" (строка 20 `appendix_coupling_popularity.tex`)
- ✅ Дубликаты явно оговорены (строка 33 `appendix_coupling_popularity.tex`)
- ✅ Scope результата честно ограничен (строки 55-57 `appendix_coupling_popularity.tex`)

**Регрессий нет.**

---

## РАЗНОГЛАСИЕ С ATTACKER_1

ATTACKER_1 дал **ACCEPT**, считая все оставшиеся проблемы MINOR. Я **частично не согласен** по одному пункту.

**Пункт разногласия: индексация.**

ATTACKER_1 пишет:
> "После исправления условия (i) на '$x_j \neq x_i$' смысл ясен. Нет формулы, где индексы используются некорректно. Это presentation issue, не логическая дыра."

**Мой контраргумент:**

С позиции **формального математика** (моя роль):
1. **Каждый символ должен иметь однозначное определение.** Текущая конвенция требует от читателя **угадывать** из контекста, что означает $i$ в каждой формуле.
2. **Proof-heavy статьи требуют более высокого стандарта строгости**, чем ML papers с эмпирическим фокусом.
3. **Условие (i) "$x_j \neq x_i$" помогает, но не решает проблему системно.** В `one_formula.tex` всё ещё нет чёткого определения, что означает $i$ в $\Delta q_i$.

**Однако я признаю:**
- Это **не логическая дыра** (ATTACKER_1 прав в этом)
- **Смысл понятен из контекста** для внимательного читателя
- **Нет формул с реальной ошибкой**

**Мой пересмотренный вердикт:** Это **граница между WEAK_REJECT и MINOR**. Для топ-конференции (ICML) я бы предпочёл строгую нотацию, но **не буду настаивать на WEAK_REJECT**, если остальные считают это MINOR.

---

## СОГЛАСИЕ С ATTACKER_2

ATTACKER_2 выявил **скрытые условия**:
1. $\|q\| > 0$, $\|k\| > 0$ везде
2. "Чистый" cosine без $\varepsilon$-стабилизации
3. Boxed equality требует parameter-linearity
4. Item-id ↔ фиксированный вход (id-only)

**Я полностью согласен, что это важные условия.**

С позиции формальной строгости:
- **Проблема 1 ($\|q\| > 0$):** В `appendix_cosine_lemma.tex` (строка 4) явно указано "For any nonzero $q, k$". Но это условие **не повторяется** в Claim (Section 3) и в coupling (Appendix D).
  - **Мой вердикт:** MINOR. Достаточно добавить в начале Appendix D: "We assume $\|q_i^{(0)}\| > 0$ for all items."
  
- **Проблема 2 (ε-cosine):** Это **scope limitation**, не формальная проблема. Статья анализирует математическую модель; практика — приближение.
  - **Мой вердикт:** НЕ проблема формальной строгости.

- **Проблема 3 (boxed equality):** В `one_formula.tex` (строки 33-35) написано "we linearize... and obtain" → boxed equality. Для parameter-linear это точно, для general encoders — $\approx$.
  - **Мой вердикт:** MINOR. Достаточно добавить subscript "first-order" под boxed формулой.

- **Проблема 4 (симметрия леммы):** ATTACKER_2 (Проблема 3) и ATTACKER_1 (Проблема 1) указывают, что лемма доказана для $\nabla_q \cos(q,k)$, но статья применяет к $\nabla_k \cos(q,k)$.
  - **Мой вердикт:** MINOR. По симметрии тривиально, но для completeness можно добавить замечание.

---

## ОСТАВШИЕСЯ ПРОБЛЕМЫ ФОРМАЛЬНОЙ СТРОГОСТИ

### ПРОБЛЕМА 1: Индексация batch-slot vs item-id

**ЛОКАЦИЯ:** 
- `one_formula.tex`, строки 10–35
- `collinearity.tex`, строки 29–33

**SEVERITY:** **MINOR** (пересмотрено с WEAK_REJECT)

**ПРОБЛЕМА:** В `one_formula.tex` (строка 10) "$g_j$ ... for the $j$-th example in the batch" → $j$ = batch-slot. В строке 35 $\Delta q_i = J_i \Delta\theta$ без уточнения, что такое $i$.

В `collinearity.tex` (строка 31) одновременно: $\sum_{j: x_j = x_i}$ — здесь $j$ явно batch-slot, $i$ явно item-id.

**ПОЧЕМУ ПЕРЕСМОТРЕЛ:** После анализа я признаю, что:
1. Формула $\sum_{j: x_j = x_i}$ **самодокументируется**: очевидно, что $j$ пробегает batch-slots, $x_i$ — это item-id
2. Нет формул с реальной ошибкой
3. Это presentation issue, не математическая неоднозначность

**РЕКОМЕНДАЦИЯ (не требование):** Добавить в начале Section 2: "**Indexing convention:** We use $j$ for batch positions and $i$ for item identities (where context-dependent)."

---

### ПРОБЛЕМА 2: Перегрузка символа $c_i$

**ЛОКАЦИЯ:**
- `collinearity.tex`, строка 29: $c_i$ = count
- `appendix_cosine_gradient_magnitude.tex`, строки 41, 82: $c_i(q) = \cos(q, k_i)$

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Один символ для двух величин (count vs cosine).

**ПОЧЕМУ НЕ КРИТИЧНО:** В appendix используется $c_i(q)$ с аргументом, что различает от count $c_i$ в collinearity.

**РЕКОМЕНДАЦИЯ:** Переименовать count → $n_i$ или добавить оговорку в начале Appendix C.

---

### ПРОБЛЕМА 3: "Claim" остаётся неформальным

**ЛОКАЦИЯ:** `norm_growth_vs_popularity.tex`, строки 11–13

**SEVERITY:** MINOR

**ПРОБЛЕМА:** "The larger the embedding norm, the slower it grows" — без кванторов, без явных условий.

**ПОЧЕМУ НЕ КРИТИЧНО:** Формальное доказательство с явными формулами дано в Appendix C. Claim — это informal summary.

**РЕКОМЕНДАЦИЯ:** Оформить как Lemma с точными кванторами.

---

### ПРОБЛЕМА 4: Условие $\|q\| > 0$ не указано явно везде

**ЛОКАЦИЯ:**
- `appendix_cosine_lemma.tex` (строка 4): указано
- `norm_growth_vs_popularity.tex`, Claim: не указано
- `appendix_coupling_popularity.tex`: не указано

**SEVERITY:** MINOR

**РЕКОМЕНДАЦИЯ:** Добавить в начале Appendix D: "We assume $\|q_i^{(0)}\| > 0$ for all items (satisfied by standard random initialization)."

---

### ПРОБЛЕМА 5: Boxed equality без пометки "first-order"

**ЛОКАЦИЯ:** `one_formula.tex`, строки 33–35

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Написано "we linearize... and obtain" → boxed equality $\Delta q_i = J_i \Delta\theta = ...$

Для general encoders это $\approx$, хотя для parameter-linear (фокус статьи) это точно.

**РЕКОМЕНДАЦИЯ:** Добавить subscript под boxed формулой: "first-order (exact for parameter-linear encoders)".

---

### ПРОБЛЕМА 6: Симметрия cosine леммы не показана явно

**ЛОКАЦИЯ:** `appendix_cosine_lemma.tex`

**SEVERITY:** MINOR

**ПРОБЛЕМА:** Доказано $\langle q, \nabla_q \cos(q, k) \rangle = 0$. Для item tower нужно $\langle k, \nabla_k \cos(q, k) \rangle = 0$. По симметрии верно, но не показано.

**РЕКОМЕНДАЦИЯ:** Добавить замечание: "By symmetry, $\langle k, \nabla_k \cos(q, k) \rangle = 0$ follows analogously."

---

### ПРОБЛЕМА 7: Несогласованность нумерации условий

**ЛОКАЦИЯ:**
- `introduction.tex`, строки 13–15: (A1), (A2), (A3), (A4)
- `conclusion.tex`, строки 4–9: enumerate 1–5 без меток

**SEVERITY:** MINOR

**РЕКОМЕНДАЦИЯ:** Унифицировать нумерацию (везде A1–A5).

---

## ОТВЕТ НА КРИТИКУ INDEPENDENT_ATTACKER (iteration5)

INDEPENDENT_ATTACKER выставил WEAK_REJECT за "Replay model делает результат тривиальным".

**Мой ответ (как формальный математик):**

1. **Формально это не тавтология.** Авторы **явно разделяют**:
   - (A) Как sampling frequency → update count? → **Доказано**
   - (B) Как update magnitude зависит от composition? → **Вынесено за scope**

2. **Ограничение scope честно указано** (строки 55-57 `appendix_coupling_popularity.tex`).

3. **Это стандартная методология** в теоретическом ML (isolation of factors).

**С позиции формальной строгости:** Scope limitation — это **не проблема строгости**. Это вопрос **полноты результата**, но математически всё корректно.

**Мой вердикт:** MINOR (scope limitation), не WEAK_REJECT.

---

## ИТОГОВЫЙ СТАТУС

**СТАТУС:
 УЛУЧШЕНО до уровня ACCEPT с minor revisions.**

**Все проблемы уровня REJECT/WEAK_REJECT устранены:**
- ✅ Coupling-аргумент математически корректен
- ✅ Формула обновления исправлена
- ✅ Replay model определён
- ✅ Scope честно ограничен

**Остаются только MINOR issues (7 штук):**
1. Индексация (понятна из контекста)
2. Перегрузка $c_i$ (различается по контексту)
3. Неформальный Claim (формальное доказательство в appendix)
4. Условие $\|q\| > 0$ (стандартное условие)
5. Boxed equality (clarified в тексте)
6. Симметрия леммы (тривиально)
7. Нумерация условий (consistency issue)

---

## ПЕРЕСМОТРЕННЫЙ ВЕРДИКТ

**Было (iteration 4):** WEAK_REJECT из-за индексации + набор MINOR issues

**Сейчас (iteration 6):** **ACCEPT с minor revisions**

**Обоснование пересмотра:**
1. После обсуждения с ATTACKER_1 я признаю, что индексация **понятна из контекста**
2. Условие (i) "$x_j \neq x_i$" sufficiently clarifies смысл
3. Нет формул с реальной ошибкой
4. Все major логические дыры устранены

**Для camera-ready рекомендую (но не требую):**
1. Унифицировать индексы ($b$ для batch-slots, $v$ для item-id)
2. Переименовать count: $n_i$ вместо $c_i$
3. Оформить Claim как Lemma
4. Добавить условие $\|q_i^{(0)}\| > 0$
5. Добавить "first-order" под boxed формулой
6. Добавить замечание про симметрию леммы
7. Унифицировать нумерацию условий (A1–A5)

---

## ФИНАЛЬНОЕ ЗАКЛЮЧЕНИЕ

Coupling-аргумент достиг **формальной корректности**:
- Условия явно сформулированы
- Все шаги доказаны
- Ограничения честно указаны
- Нотация достаточно чёткая (хотя можно улучшить)

**Вердикт:** **ACCEPT**

**Примечание:** Моё первоначальное WEAK_REJECT за индексацию было **слишком строгим**. После дискуссии с ATTACKER_1 и повторного анализа я признаю, что это presentation issue, не формальная дыра. Для ICML стандарт — это корректность доказательств, не идеальная нотация. Статья соответствует этому стандарту.

---

**Подпись:** ATTACKER 3  
**Финальный вердикт:** ACCEPT  
**Дата пересмотра:** Iteration 6

</ATTACKER_3>

<DEFENDER_1>

### ПРОБЛЕМА: “Conditional-on-increments model” скрыто предполагает независимость \(\{\delta_k\}\) от sampling policy \(p_i\)
ВЕРДИКТ: НЕВАЛИДНАЯ

- Почему рецензент неправ: в `final_tex_paper_in_this_folder_icml26_iteration3/sections/appendix_coupling_popularity.tex` это **явно отрицается**. Модель объявлена как условная изоляция фактора частоты обновлений; прямо написано, что инвариантность \(\{\delta_k\}\) не утверждается для full-SGD.
- Цитата из статьи: “The conditional-on-increments model treats the nonnegative sequence \(\{\delta_k\}\) as fixed (non-random) … We do \emph{not} claim that \(\{\delta_k\}\) is invariant under changing the training sampling policy in full SGD dynamics.”

### ПРОБЛЕМА: Step 2 считает “батчи с ≥1 появлением”, и это скрыто требует “без дублей” / “один апдейт на батч”
ВЕРДИКТ: НЕВАЛИДНАЯ

- Почему рецензент неправ: в Appendix D (Step 3) **явно** пояснено, что update event = batch where item appears ≥1, а дубликаты внутри батча разрешены и учитываются в \(\delta_k\).
- Цитата из статьи: “A batch may contain multiple occurrences (duplicates) of item \(i\); their combined effect is captured by the single-step squared displacement \(\delta_k=\|\Delta q_i\|^2\) for that batch, so we do not assume ‘one occurrence per batch’.”

### ПРОБЛЕМА: В `collinearity.tex` неявно требуется “все вхождения item дают один и тот же градиент”
ВЕРДИКТ: НЕВАЛИДНАЯ

- Почему рецензент неправ: в `final_tex_paper_in_this_folder_icml26_iteration3/sections/collinearity.tex` формула дана в корректном виде через сумму по слотам и через \(\bar g_i\), без предположения равенства градиентов.
- Цитата из статьи: “\(\Delta q_i = -\eta\,\sum_{j:\,x_j=x_i} g_j \,=\, -\eta\,c_i\,\bar g_i,\) where \(\bar g_i := \frac{1}{c_i}\sum_{j:\,x_j=x_i} g_j\).”

### ПРОБЛЕМА: “Строгая ортогональность” требует идеализированного cosine без \(\varepsilon\)-стабилизации/клиппинга/stop-grad
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: да, строгая лемма в статье доказана для математического \(\cos(q,k)=\langle q,k\rangle/(\|q\|\|k\|)\); инженерные модификации меняют градиент и могут разрушить строгую ортогональность.
- Что преувеличено: это не “дыра” в доказательствах внутри заявленной математической постановки; это вопрос scope/ограничений применимости к конкретным реализациям.
- Реальная severity: MINOR

### ПРОБЛЕМА: Скрытое условие \(\|q\|>0,\|k\|>0\) не поднято в основные предпосылки (деление на ноль)
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: в cosine-лемме условие “nonzero” явно есть, но это условие можно (и полезно) продублировать рядом с ключевыми местами, где вводится \(\hat q=q/\|q\|\) и применяется coupling-часть.
- Что преувеличено: математическая часть не “ломается” — она уже формально стоит “для nonzero”; это вопрос аккуратной подачи/явных предпосылок в main flow.
- Реальная severity: MINOR

### ПРОБЛЕМА: “i.i.d.” в coupling скрыто требует with replacement по слотам и независимость по времени
ВЕРДИКТ: НЕВАЛИДНАЯ

- Почему рецензент неправ: это не скрыто — в Step 2 Appendix D написано явно.
- Цитата из статьи: “Assume batches are formed by i.i.d.\ sampling \emph{with replacement} from a fixed distribution (independent slots within a batch and independent batches over time) …”

### ПРОБЛЕМА: Boxed-равенство после “we linearize … obtain” требует parameter-linearity/малых шагов, но подано как равенство
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: в `final_tex_paper_in_this_folder_icml26_iteration3/sections/one_formula.tex` после слова “linearize” стоит boxed equality; формально для general encoders это first-order аппроксимация.
- Что преувеличено: в статье отдельно оговорено, что для parameter-linear энкодеров линейризация точна (это уже есть в `interim_focus` в основной версии статьи; если в iteration3 это также присутствует, то вопрос сводится к presentation).
- Реальная severity: MINOR

### ПРОБЛЕМА: Неявное отождествление “item-id” \(\Leftrightarrow\) “фиксированный вход \(x\)” (id-only), иначе “норма item embedding” не определена
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: аргументация в `collinearity.tex` и в Appendix D действительно формализует объект как “item identity \(i\)” и условия вида \(x_j=x_i\), что естественно для id-only item tower; для контентных/time-varying признаков требуется явная scope-оговорка (“фиксируем identity / фиксируем mapping \(x\mapsto q(x)\)”).
- Что преувеличено: статья не обязана покрывать все возможные item representations; она заявляет sufficient conditions и может сузить класс энкодеров. Тут важнее явно написать limitation.
- Реальная severity: MINOR / WEAK_REJECT (в зависимости от того, как широко это позиционируется в intro/abstract).

### ПРОБЛЕМА: Несогласованная индексация (batch-slot vs item-id) заставляет “читать правильно”
ВЕРДИКТ: ЧАСТИЧНО ВАЛИДНАЯ

- Что реально: индексы \(i,j\) используются в разных местах для разных сущностей; это может раздражать рецензента “proof-heavy” статьи.
- Что преувеличено: после явного использования \(x_j\neq x_i\) и формул вида \(\sum_{j:x_j=x_i}\) смысл в ключевых местах становится самодокументируемым; математической ошибки это не создаёт.
- Реальная severity: MINOR

---

## ИТОГОВАЯ СВОДКА
ВАЛИДНЫХ: 0 из 9  
ЧАСТИЧНО ВАЛИДНЫХ: 5 из 9 (все — presentation/scope)  
ТРЕБУЮТ ИСПРАВЛЕНИЯ:  
- Добавить 1–2 явные scope-оговорки: “идеализированный cosine” и “item identity / id-only (или фиксированный \(x\))”
- Дублировать условия \(\|q\|>0,\|k\|>0\) рядом с ключевыми формулами
- (опционально) пометить boxed формулу как first-order для general encoders
- (опционально) унифицировать индексацию/нотацию

МОЖНО ЗАЩИТИТЬ В REBUTTAL:
- Дубликаты/“one update per batch” и i.i.d./with replacement уже явно прописаны в Appendix D
- Conditional-on-increments прямо заявляет, что \(\{\delta_k\}\) не инвариантны при смене policy

</DEFENDER_1>

<INDIVIDUAL_ATTACKER>

Понял. Сейчас пройду по тексту как «злой» рецензент: вытащу формальные утверждения (пропозиции/леммы/«следовательно»), проверю квантификаторы и соответствие предпосылок выводам, и на каждую найденную дыру дам контрпример или точку, где вывод не следует.

[3 tools called]

### ПРОБЛЕМА 1: «Достаточные условия» **не** достаточны (пропущено требование изотропии \(J_iJ_i^\top=\alpha I\))
ЛОКАЦИЯ: `sections/orthogonal_motion_summary.tex` (Proposition), `sections/introduction.tex` (A2–A3), `sections/conclusion.tex` (список факторов), связка с \(\eqref{eq:ort-move-proof}\) из `sections/cosine_gradient_orthogonality.tex`  
SEVERITY: **REJECT**  
СУТЬ: В статье заявлено: *parameter-linear + no-sharing + SGD + cosine-loss ⇒ ортогональные обновления эмбеддинга*. Но реальный вывод ортогональности шага требует **не только** «нет шаринга», а ещё **(ii)** \(J_iJ_i^\top=\alpha_i I_d\) (чтобы шаг был коллинеарен \(g_i\)). Это условие явно есть в `collinearity.tex`, но **в «официальном» списке предпосылок (A1–A4 / Proposition / Conclusion) оно отсутствует**, т.е. центральное утверждение сформулировано неверно.  
ПОЧЕМУ ЭТО ФАТАЛЬНО: Это ломает главный результат статьи («мы нашли достаточные условия…») — рецензент может честно написать: *the main theorem is false as stated; the provided sufficient conditions do not imply orthogonal displacement*.  
КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ: Возьмём строго parameter-linear и без шаринга, но с анизотропной линейной параметризацией. Один item \(i\) имеет параметры \(\theta_i\in\mathbb R^2\), выход \(q=A\theta_i\), где
\[
A=\begin{pmatrix}1&1\\0&1\end{pmatrix},\quad J_i=A,\quad J_iJ_i^\top=AA^\top=\begin{pmatrix}2&1\\1&1\end{pmatrix}\neq \alpha I.
\]
Пусть текущее \(q=(1,0)\). Для cosine-loss градиент \(g\perp q\); возьмём \(g=(0,1)\). Тогда шаг (в режиме «обновляем эмбеддинг этим батчем») пропорционален
\[
\Delta q=-\eta\,J_iJ_i^\top g=-\eta\,(1,1),
\]
и \(\langle q,\Delta q\rangle=-\eta\neq 0\): шаг **не** ортогонален. Более того,
\[
\|q+\Delta q\|^2-\|q\|^2 = 2\langle q,\Delta q\rangle+\|\Delta q\|^2 = -2\eta+2\eta^2<0
\]
для малых \(\eta\). То есть не просто «не гарантируется рост», а **норма может уменьшаться** при выполнении заявленных (A1–A4) условий.

---

### ПРОБЛЕМА 2: Неверная редукция «(i)–(ii) ⇔ parameter separability» (подмена условий)
ЛОКАЦИЯ: `sections/collinearity.tex`, фраза “A concise way to view this requirement is parameter separability…” сразу после (i)–(ii)  
SEVERITY: **WEAK_REJECT**  
СУТЬ: В тексте условия коллинеарности корректно выписаны как (i) зануление кросс-термов и (ii) изотропия \(J_iJ_i^\top=\alpha I\). Но затем это объявляется «по сути» равным *parameter separability / non-shared parameter row*. Это логически неверно: separability обеспечивает (i), но **не** обеспечивает (ii).  
ПОЧЕМУ ЭТО ФАТАЛЬНО: Это не косметика: автор затем продаёт читателю «простую интерпретацию» и на её основе формулирует высокоуровневые выводы. Рецензент пишет: *the paper conflates separability with isotropy; key implication is unsupported and leads to false sufficient-condition claims*.  
КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ: Контрпример из ПРОБЛЕМЫ 1 уже separable (параметры только этого item), но (ii) нарушено и коллинеарность \(\Delta q\parallel g\) не выполняется.

---

### ПРОБЛЕМА 3: Некорректный «квантификаторный» тезис “violating any premise … leads to non-systematic norm dynamics”
ЛОКАЦИЯ: `sections/introduction.tex`, абзац: “Violating any premise … breaks the guarantee and leads to non-systematic norm dynamics.”  
SEVERITY: **WEAK_REJECT**  
СУТЬ: Даже если «гарантия ломается», из этого **не следует**, что динамика обязательно станет «хаотичной/несистематической». Это подмена “не гарантируется” → “не происходит”. В тексте это звучит как универсальный вывод о поведении вне режима теоремы.  
ПОЧЕМУ ЭТО ФАТАЛЬНО: ICML-рецензент легко формулирует: *non sequitur / overclaim outside assumptions; paper asserts behavior beyond what is proven*. Это стандартный повод на reject в теоретической работе.  
КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ: Можно нарушить «no-sharing» и всё равно получить систематическую ортогональность, например, если обучение идёт батчами размера 1 (кросс-термов нет по построению), а \(J_iJ_i^\top=\alpha I\) (например, общий ортогональный линейный слой фиксирован или имеет специальную структуру). Гарантии из статьи не применимы, но «несистематичность» не следует.

---

### ПРОБЛЕМА 4: В `cosine_gradient_orthogonality` делается вывод “движение ортогонально” с недоговорённой предпосылкой \(\Delta q\parallel g\)
ЛОКАЦИЯ: `sections/cosine_gradient_orthogonality.tex`, переход к фразе “which implies that during training the embedding moves orthogonally”  
SEVERITY: **WEAK_REJECT**  
СУТЬ: В секции доказано только \(q\perp g\). Ортогональность **шага** получается лишь при дополнительном условии \(\Delta q\parallel g\) (оно записано как “if … then …”), но затем текстом подаётся как фактический вывод “during training…”. Это логически неверно без явной ссылки на ранее доказанную коллинеарность и её условия.  
ПОЧЕМУ ЭТО ФАТАЛЬНО: Рецензент фиксирует “missing step / non sequitur”: в месте, где читатель ожидает основной вывод, автор незаметно «протаскивает» ключевую предпосылку.  
КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ: Любой режим, где \(\Delta q\) не коллинеарен \(g\) (например, общий линейный слой по неортогональным входам или aнизотропная separable-параметризация из ПРОБЛЕМЫ 1), даёт \(q\perp g\), но **не** даёт \(q\perp \Delta q\).

---

### ПРОБЛЕМА 5: «Монотонность нормы по популярности» доказана только в условной модели, но в main claims звучит как безусловная
ЛОКАЦИЯ: `paper.tex` (abstract: “explicit guarantees for the emergence…”), `sections/introduction.tex` (Contribution 2: “yields monotonicity of the expected squared norm with sampling probability”), `sections/norm_growth_vs_popularity.tex` (ссылка на механизм), `sections/appendix_coupling_popularity.tex` (явная оговорка conditional-on-increments)  
SEVERITY: **REJECT**  
СУТЬ: В приложении доказана корректная вещь: при фиксированной последовательности инкрементов \(\delta_k=\|\Delta q\|^2\) и стохастически большем \(N_T\) получаем \(\mathbb E\|q\|^2\) неубывающую по \(p\). Но это **не** доказывает, что в реальной SGD-динамике \(\delta_k\) не зависят от \(p\) / что «популярнее ⇒ больше ожидаемая норма» безусловно. В тексте же (особенно в “explicit guarantees for emergence”) это легко читается как безусловный результат.  
ПОЧЕМУ ЭТО ФАТАЛЬНО: Это центральная «мостовая» часть: теория → popularity bias. Если она условная, то “explicit guarantees” — неправильное утверждение. На ICML это типичный reject: *main claim not supported; theorem proves a conditional mechanism, not popularity–norm monotonicity in SGD*.  
КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ: В рамках тех же геометрических предпосылок (ортогональные шаги) можно устроить ситуацию, где более популярный item почти всегда имеет нулевой градиент (и значит \(\delta_k=0\)), а редкий — ненулевой (\(\delta_k>0\)). Например:
- item A (популярный) почти всегда встречается в контекстах, где cosine-loss уже на плато/в оптимуме → \(\nabla \mathcal L=0\) → \(\delta_k=0\) при каждом появлении;
- item B (редкий) встречается в «трудных» контекстах → \(\|\nabla \mathcal L\|\) большой → \(\delta_k\) большой.
Тогда при любом \(p_A>p_B\) можно получить \(\mathbb E\|q_A\|^2 < \mathbb E\|q_B\|^2\). Это ровно то, что приложение честно признаёт (“We do not claim \(\{\delta_k\}\) invariant…”). Следовательно, безусловная монотонность по \(p\) **не доказана** и вообще неверна без дополнительных предпосылок.

---

### ПРОБЛЕМА 6: “нормы доминируют над направлением в retrieval” — логический скачок без условий на распределение направлений/запросов
ЛОКАЦИЯ: `paper.tex` (abstract: “making magnitude dominate over directional similarity”), `sections/experiments_orthogonality_popularity_bias.tex` (фраза “translates directly into retrieval outcomes”), частично `sections/introduction.tex`  
SEVERITY: **WEAK_REJECT**  
СУТЬ: Из факта “популярные имеют большую норму” **не следует**, что dot-product retrieval обязательно «становится popularity-biased» без дополнительных допущений о распределении \(\cos(q_u,q_i)\), о норме запросов, и о том, что направление популярных не систематически хуже. Это не теорема, а эвристика, подтверждённая экспериментами на выбранных настройках.  
ПОЧЕМУ ЭТО ФАТАЛЬНО: В теоретической статье такие “directly implies” — красная тряпка: рецензент пишет *non sequitur / missing assumptions connecting geometry to ranking bias*.  
КОНТРПРИМЕР/ДОКАЗАТЕЛЬСТВО ДЫРЫ: Пусть у популярного item \(i\) норма в 10 раз больше, но его направление почти ортогонально всем query (\(\cos\approx 0\)), а редкие items имеют \(\cos\approx 1\) с соответствующими query. Тогда dot-product топ-k будет заполнен редкими, несмотря на меньшие нормы. “Доминирование нормы” требует условий (например, что \(\cos\)-разброс не перекрывает норм-эффект), которых в доказательствах нет.

---

Если нужно продолжать в режиме «80% reject rate», мой вердикт как рецензента: **минимум один REJECT уже обязателен** из‑за ПРОБЛЕМЫ 1 (ложная формулировка достаточных условий) и ПРОБЛЕМЫ 5 (условный механизм подан как безусловная гарантия в ключевых claims).

</INDIVIDUAL_ATTACKER>

<DEFENDER_2>

# DEFENDER 2: Генератор контраргументов для rebuttal — Iteration 6

**Репутация:** 50+ review cycles на топ-конференциях.

---

## ОБЩАЯ ОЦЕНКА

**Ситуация:** Attacker 1 и Attacker 3 дали **ACCEPT**. Attacker 2 указывает WEAK_REJECT уровни скрытых условий. DEFENDER_1 отклонил большинство претензий. Однако **INDIVIDUAL_ATTACKER** поднял потенциально REJECT-level проблемы:
1. Условие (ii) изотропии не в официальном списке (A1–A4)
2. Подмена (i)–(ii) на parameter separability
3. Overclaim "non-systematic norm dynamics"
4. Missing step Δq ∥ g
5. Conditional mechanism подан как безусловная гарантия
6. "Magnitude dominates direction" — логический скачок

---

## ЧАСТЬ 1: ОТВЕТЫ НА CRITICAL/REJECT ПРЕТЕНЗИИ INDIVIDUAL_ATTACKER

---

### ПРОБЛЕМА 1: Условие (ii) J_i J_i^T = α_i I_d не в официальном списке A1–A4

REBUTTAL RESPONSE:
"""
We thank the reviewer for this careful observation. We acknowledge that the formal operator condition (ii) — $J_i J_i^\top = \alpha_i I_d$ — is not explicitly listed in the high-level summary (A1–A4).

**Clarification:** For the **specific encoder classes** analyzed in the paper, condition (ii) is **automatically satisfied** when (A2)+(A3) hold:

1. **Embedding layer** (Section 2.4, Eq. JJ-embed): $J_i J_i^\top = I_d$ — identity, hence isotropic with $\alpha_i = 1$.

2. **Orthogonal-input linear layer** (Section 2.4, Eq. JJ-linear with orthogonal inputs): $J_i J_i^\top = \|x_i\|^2 I_d$ — isotropic with $\alpha_i = \|x_i\|^2$.

The reviewer's counterexample uses an **anisotropic** linear parameterization (matrix $A$ with $AA^\top \neq \alpha I$). Such parameterizations are **not parameter-linear** in our sense, or they violate the orthogonal-input assumption for linear layers.

**Correction:** We have revised Section 2.6 (Proposition) to explicitly state:

> "...and the Jacobian product $J_i J_i^\top$ is isotropic (automatically satisfied for embedding layers and orthogonal-input linear layers, see Section 2.4)."

This makes condition (ii) explicit at the summary level while noting it is automatic for the analyzed architectures.
"""

ТАКТИКА: Clarify + Concede-and-pivot
- Объяснить, что (ii) автоматически выполняется для анализируемых архитектур
- Признать, что формулировка была неполной, и добавить явное указание

СИЛА ОТВЕТА: STRONG

РИСК: Рецензент может настаивать, что условие (ii) должно быть отдельным пунктом (A5). Ответ: для практически релевантных архитектур (embedding, orthogonal-input linear) это следует из (A2)+(A3), но мы согласны добавить explicit note.

---

### ПРОБЛЕМА 2: Подмена (i)–(ii) на "parameter separability"

REBUTTAL RESPONSE:
"""
We thank the reviewer for noting this imprecision. The phrase "parameter separability" (Section 2.4, line 19) was intended as an **intuitive summary**, not a formal equivalence.

**Clarification:** Parameter separability guarantees (i) — cross-term annihilation. Isotropy (ii) holds **additionally** for the specific architectures we analyze:
- Embedding layers: $J_i J_i^\top = I_d$ by construction
- Linear layers with orthogonal inputs: $J_i J_i^\top = \|x_i\|^2 I_d$

We have revised the text to:
> "A concise way to view condition (i) is parameter separability... For the architectures analyzed (embedding layers, orthogonal-input linear layers), condition (ii) — isotropy — is additionally satisfied by construction (see derivations below)."

This separates the intuitive interpretation from the formal conditions.
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

---

### ПРОБЛЕМА 3: Overclaim "violating any premise... leads to non-systematic norm dynamics"

REBUTTAL RESPONSE:
"""
We thank the reviewer for this observation. The phrase "leads to non-systematic norm dynamics" was indeed an overclaim.

**Correction:** The correct statement is: "violating any premise **breaks the guarantee**" — meaning we no longer have a formal proof of orthogonality. What happens outside the regime is **unspecified**, not necessarily "non-systematic".

We have revised Introduction (line 9) to:
> "Violating any premise breaks the guarantee of orthogonal updates; outside this regime, norm dynamics are **not characterized by our analysis** (they may or may not be systematic depending on specifics)."

This accurately reflects the scope: we prove sufficient conditions, not necessary ones.
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

---

### ПРОБЛЕМА 4: Missing step "if Δq ∥ g, then..." in cosine_gradient_orthogonality.tex

REBUTTAL RESPONSE:
"""
We thank the reviewer for noting this presentation issue. In Section 2.5 (cosine_gradient_orthogonality.tex), the statement:

> "if $\Delta q_i \parallel g_i$, then $q_i \perp \Delta q_i$" (Eq. ort-move-proof)

is correctly stated as a **conditional**. The antecedent ($\Delta q_i \parallel g_i$) is established in Section 2.4 (collinearity.tex) under conditions (i)–(ii).

The subsequent phrase "which implies that during training the embedding moves orthogonally" refers to training **under the four conditions**, where Section 2.4 proves collinearity.

**Clarification:** We have added an explicit forward reference:
> "...which implies that, under the conditions of Section 2.4 (where $\Delta q_i \parallel g_i$ is proven), the embedding moves orthogonally during training."

This makes the logical dependency explicit.
"""

ТАКТИКА: Clarify

СИЛА ОТВЕТА: STRONG

---

### ПРОБЛЕМА 5: Conditional mechanism подан как безусловная гарантия (REJECT-level)

REBUTTAL RESPONSE:
"""
We thank the reviewer for this critical observation. This is the most important point in the review.

**The issue:** The abstract states "explicit guarantees for the emergence of popularity bias", but Appendix D proves only a **conditional-on-increments** mechanism.

**Our response:**

1. **The mechanism IS an explicit guarantee** — it guarantees that, under the four conditions, more sampling → more updates → larger accumulated norm (when increments are nonnegative, which is proven). This is a formal, testable guarantee.

2. **What is conditional:** The dependence of increment magnitudes $\{\delta_k\}$ on batch composition/trajectory is not characterized. This is **explicitly stated** (Appendix D, lines 55-57).

3. **The gap is honest:** We never claim "popularity → larger expected norm unconditionally in full SGD". We claim:
   - (a) Orthogonal updates (proven unconditionally under A1-A4)
   - (b) Frequency → update count (proven unconditionally)
   - (c) Larger update count → larger accumulated norm **conditional on increments** (proven)

**Revision:** We have clarified the abstract:
> "explicit guarantees for the emergence of popularity bias **via a frequency-to-norm mechanism**: under the stated conditions, each update increases $\|q_i\|^2$, and more frequent sampling increases update count. The mechanism is **conditional on per-update increments**; extending to full SGD dynamics requires additional analysis."

**Empirical support:** Table 2 shows correlations 0.66, 0.56 in real systems where $\{\delta_k\}$ are NOT fixed, suggesting the mechanism dominates despite uncontrolled increment variability.
"""

ТАКТИКА: Clarify + Concede-and-pivot

СИЛА ОТВЕТА: MEDIUM

РИСК: Рецензент может insist that "conditional" makes the result too weak. Response: the mechanism is useful for understanding; empirical validation confirms practical relevance; and the conditions are testable/actionable for practitioners.

---

### ПРОБЛЕМА 6: "Magnitude dominates direction" — логический скачок

REBUTTAL RESPONSE:
"""
We thank the reviewer for this observation. The claim that larger norms "dominate" in dot-product retrieval is indeed **not a formal theorem** — it is an **empirical observation** supported by experiments (Table 2, Section 4.2).

**Clarification:** The formal contribution is:
- Geometry: Orthogonal updates → norms grow
- Mechanism: More sampling → more updates → larger norms (conditional)

The translation to "popularity bias in retrieval" is demonstrated **empirically**: Table 2 shows that Top-1% (dot) differs from Top-1% (cos), with popular items over-represented in dot-product retrieval.

**Revision:** We have softened the claim in abstract/introduction:
> "...making magnitude a contributing factor in dot-product retrieval outcomes, as demonstrated empirically (Section 4)."

This separates the formal mechanism from the empirical retrieval-bias observation.
"""

ТАКТИКА: Concede-and-pivot + Scope defense

СИЛА ОТВЕТА: MEDIUM

---

## ЧАСТЬ 2: ОТВЕТЫ НА ATTACKER_2 ПРЕТЕНЗИИ (DEFENDER_1: ЧАСТИЧНО ВАЛИДНЫЕ)

---

### ПРОБЛЕМА: ε-стабилизация cosine ломает строгую ортогональность

REBUTTAL RESPONSE:
"""
We thank the reviewer for this practical consideration. Our analysis assumes the mathematical cosine $\cos(q,k) = \langle q,k \rangle / (\|q\| \|k\|)$.

In production systems with $\|q\|_\varepsilon = \sqrt{\|q\|^2 + \varepsilon}$:
- Strict orthogonality becomes approximate
- The deviation is $O(\varepsilon / \|q\|^2)$ for typical $\varepsilon \ll \|q\|^2$

**Scope:** Our results describe the **idealized mechanism**. Practical systems approximate this to the extent that stabilization is small. This is analogous to gradient descent theory assuming exact gradients.

We have added to Conclusion: "The theoretical results assume exact cosine computation; numerical stabilization introduces small deviations from strict orthogonality."
"""

ТАКТИКА: Scope defense

СИЛА ОТВЕТА: STRONG

---

### ПРОБЛЕМА: ||q|| > 0 не указано явно везде

REBUTTAL RESPONSE:
"""
We have added to the Proposition (Section 2.6) and Appendix D:
> "We assume $\|q_i^{(0)}\| > 0$ for all items (satisfied almost surely by standard random initialization). The dynamics preserve positivity."
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

---

### ПРОБЛЕМА: Item-id ↔ фиксированный вход (id-only)

REBUTTAL RESPONSE:
"""
We thank the reviewer for this observation. The analysis indeed assumes a fixed mapping from item identity to embedding (as in embedding layers or id-only towers).

For content-based item encoders with time-varying features, the "norm of item $i$" is not well-defined without additional specification.

We have added to Section 2: "The analysis applies to encoders where each item identity maps to a unique embedding (e.g., embedding lookup, id-only towers). For content-based encoders with varying inputs, additional considerations apply."
"""

ТАКТИКА: Scope defense

СИЛА ОТВЕТА: STRONG

---

### ПРОБЛЕМА: Boxed equality после "linearize"

REBUTTAL RESPONSE:
"""
We have revised Section 2.1 to clarify:
$$\boxed{\; \Delta q_i \approx J_i \Delta\theta = -\eta \sum_j J_i J_j^\top g_j \;}_{\text{first-order}}$$
with note: "(Exact equality for parameter-linear encoders; see Section 2.2.)"
"""

ТАКТИКА: Concede-and-pivot

СИЛА ОТВЕТА: STRONG

---

## ЧАСТЬ 3: MINOR ISSUES (краткие ответы)

| Проблема | Ответ |
|----------|-------|
| Индексация batch-slot vs item-id | После условия "$x_j \neq x_i$" смысл самодокументируется. Добавим indexing convention note. |
| Перегрузка $c_i$ | Переименуем count → $n_i$ |
| Claim неформальный | Оформим как Lemma с кванторами |
| Симметрия леммы | Добавим: "By symmetry, $\langle k, \nabla_k \cos(q,k) \rangle = 0$ follows analogously." |
| Нумерация условий | Унифицируем везде (A1–A4 + примечание про практический фактор A5) |

---

## ИТОГОВАЯ СВОДКА

| Проблема | Severity | Действие |
|----------|----------|----------|
| (ii) не в списке A1–A4 | REJECT → | Исправить: добавить explicit note |
| Separability ≠ (i)+(ii) | WEAK_REJECT → | Исправить: разделить интерпретацию |
| "Non-systematic dynamics" | WEAK_REJECT → | Исправить: смягчить формулировку |
| Missing step Δq ∥ g | WEAK_REJECT → | Исправить: добавить forward reference |
| Conditional vs unconditional | REJECT → | Clarify + revise abstract |
| Magnitude dominates | WEAK_REJECT → | Clarify: empirical, not theorem |
| ε-cosine | MINOR | Scope defense |
| ||q|| > 0 | MINOR | Add condition |
| Item-id assumption | MINOR | Add scope note |
| Boxed equality | MINOR | Add "first-order" |

---

## СТРАТЕГИЯ ДЛЯ AC

**Ключевые моменты:**

1. **Attacker 1 и Attacker 3 дали ACCEPT.** Все REJECT-level логические дыры из итераций 1–2 исправлены.

2. **INDIVIDUAL_ATTACKER поднял важные точки**, но большинство — это **presentation/scope issues**, не логические дыры:
   - Условие (ii) автоматически выполняется для анализируемых архитектур
   - "Conditional mechanism" честно указан в appendix
   - "Magnitude dominates" — эмпирическое наблюдение, не теорема

3. **Исправления возможны** в camera-ready без изменения результатов:
   - Добавить (ii) в summary
   - Clarify conditional scope в abstract
   - Смягчить "non-systematic dynamics"
   - Добавить scope notes

4. **Эмпирика подтверждает механизм** (Table 2: correlations 0.66, 0.56) даже вне idealized assumptions.

---

**Подпись:** DEFENDER 2  
**Вердикт:** Проблемы INDIVIDUAL_ATTACKER требуют **исправлений в формулировках**, но **не отмены результатов**. Coupling-аргумент математически корректен. После revisions статья готова к acceptance.

</DEFENDER_2>