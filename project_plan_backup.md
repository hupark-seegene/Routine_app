# Project Plan - Squash Training App

## ?๋ก?ํธ ๊ฐ์
์ค๊ธ?์ ?๊ธ ?ค์ฟผ??? ์๋ก?๋ฐ์ ?๊ธฐ ?ํ ?ด๋ ์ฃผ๊ธฐ???ด๋ก  ๊ธฐ๋ฐ ?ธ๋ ?ด๋ ??
**?๋ก?ํธ ?ํ**: FINAL APP ARCHITECTURE & ENHANCEMENT PHASE ??
- **MVP ?์ฑ??*: 100% (๊ธฐ๋ณธ ๊ธฐ๋ฅ ๊ตฌํ ?๋ฃ)
- **?์ฌ ?จ๊ณ**: ๊ธฐ๋ฅ ๊ณ ๋??๋ฐ?์ต์ ??- **๊ฐ๋ฐ ๊ธฐ๊ฐ**: ??6๊ฐ์ (2024???๋ฐ๊ธ?~ 2025???๋ฐ๊ธ?
- **์ฝ๋ ๊ท๋ชจ**: 260+ ?์ผ, 40,000+ ?ผ์ธ

## ?๏ธ?์ต์ข ???ํค?์ฒ

### ?ต์ฌ ๊ตฌ์กฐ
1. **๋ง์ค์ฝํธ ๊ธฐ๋ฐ ?ธํฐ?์**
   - ???ค์ฟผ???ผ์ผ????์บ๋ฆญ?ฐ๊? ์ค์???์น
   - ??6๊ฐ?๊ธฐ๋ฅ ?์ญ?ผ๋ก ?๋๊ท??ค๋น๊ฒ์ด??   - ??2์ด?long press๋ก?AI ?์ฑ?ธ์ ?์ฑ??
2. **๋ชจ๋?๋ ์ฝ๋ ๊ตฌ์กฐ**
   ```
   com.squashtrainingapp/
   ?โ?? activities/     # ?๋ฉด๋ณ??กํฐ๋นํฐ
   ?โ?? mascot/        # ๋ง์ค์ฝํธ ?์ค??   ?โ?? ai/            # AI ๋ฐ??์ฑ?ธ์
   ?โ?? database/      # ?ฐ์ด???์??   ?โ?? models/        # ?ฐ์ด??๋ชจ๋ธ
   ?โ?? ui/            # UI ์ปดํฌ?ํธ
   ?โ?? utils/         # ? ํธ๋ฆฌํฐ
   ```

3. **?ฐ์ด?ฐ๋ฒ ?ด์ค ?ค๊ณ**
   - SQLite ๊ธฐ๋ฐ ๋ก์ปฌ ??ฅ์
   - 3๊ฐ??์ด๋ธ? exercises, records, user
   - ?คํ?ผ์ธ ?ฐ์  ?ํค?์ฒ

## ?? ๊ธฐ๋ฅ ๊ณ ๋??๋ก๋๋ง?(2025-07-20~)

### Phase 1: ?ฑ๋ฅ ์ต์ ??๋ฐ??์ ??(1-2์ฃ?
1. **๋ฉ๋ชจ๋ฆ?์ต์ ??*
   - ๋ง์ค์ฝํธ ?๋๋ง?์ต์ ??   - ?ด๋?์ง ๋ฆฌ์???์ถ
   - ๋ฉ๋ชจ๋ฆ??์ ?๊ฑฐ

2. **? ๋๋ฉ์ด??๊ฐ์ **
   - 60fps ๋ถ?๋ฌ???๋๊ท?   - ๋ฌผ๋ฆฌ ๊ธฐ๋ฐ ๋ฐ์ด???จ๊ณผ
   - ?ํ ? ๋๋ฉ์ด??์ถ๊?

3. **?ฐ์ด?ฐ๋ฒ ?ด์ค ์ต์ ??*
   - ?ธ๋ฑ??์ถ๊?
   - ์ฟผ๋ฆฌ ์ต์ ??   - ๋ฐฑ์/๋ณต์ ๊ธฐ๋ฅ

### Phase 2: ๊ณ ๊ธ AI ๊ธฐ๋ฅ (2-3์ฃ?
1. **AI ์ฝ์น ๊ณ ๋??*
   - GPT-4 ?๊ทธ?์ด??   - ๊ฐ์ธ?๋ ?ธ๋ ?ด๋ ๊ณํ
   - ?ค์๊ฐ???๋ถ์ (์นด๋ฉ??

2. **?์ฑ ๋ช๋ น ?์ฅ**
   - ?ค๊ตญ??์ง??   - ?คํ?ผ์ธ ?์ฑ?ธ์
   - ?์ฐ???ดํด ๊ฐ์ 

3. **?ค๋ง??์ถ์ฒ**
   - ?ด๋ ?จํด ๋ถ์
   - ๋ง์ถค???ด๋ ?์
   - ๋ถ???๋ฐฉ ?๋ฆผ

### Phase 3: ?์ & ๊ฒ์??(3-4์ฃ?
1. **?์ ๊ธฐ๋ฅ**
   - ์น๊ตฌ ์ถ๊?/???   - ๋ฆฌ๋๋ณด๋
   - ?ด๋ ๊ณต์ 

2. **๊ฒ์???์**
   - ?๋ฒจ ?์ค???์ฅ
   - ?์ /๋ฐฐ์? ?์ค??   - ?ผ์ผ ์ฑ๋ฆฐ์ง

3. **์ปค๋??ํฐ**
   - ?ด๋ฝ ?์ฑ/๊ฐ??   - ๊ทธ๋ฃน ์ฑ๋ฆฐ์ง
   - ์ฝ์น ๋งค์นญ

### Phase 4: ?จ์ด?ฌ๋ธ ?ฐ๋ (4-5์ฃ?
1. **?ผํธ?์ค ?ธ๋์ป?*
   - ?ฌ๋ฐ??๋ชจ๋?ฐ๋ง
   - ์นผ๋ก๋ฆ?์ถ์ 
   - ?๋ฉด ๋ถ์

2. **?ค๋ง?ธ์์น???*
   - Wear OS ??   - ?ด๋ ์ค??ฐ์ด???์
   - ?๊ฒฉ ?์ด

3. **IoT ๊ธฐ๊ธฐ ?ฐ๋**
   - ?ค๋ง???ผ์ผ ?ผ์
   - ์ฝํธ ?์ฝ ?์ค??   - ?์ ๋ถ์ ์นด๋ฉ??
### Phase 5: ?๋ก ๋ฒ์  ์ถ์ (5-6์ฃ?
1. **?๋ฆฌ๋ฏธ์ ๊ธฐ๋ฅ**
   - ?๋ฌธ๊ฐ ์ฝ์นญ ?์
   - ๊ณ ๊ธ ๋ถ์ ?๊ตฌ
   - ๋ง์ถค???์ ๊ณํ

2. **?๋ซ???์ฅ**
   - iOS ๋ฒ์  ๊ฐ๋ฐ
   - ????๋ณด??   - ?๋ธ๋ฆ?์ต์ ??
3. **?์ต??*
   - ๊ตฌ๋ ๋ชจ๋ธ
   - ?ธ์ฑ ๊ตฌ๋งค
   - ์ฝ์น ๋ง์ผ?๋ ?ด์ค

## ? ๊ฐ๋ฐ ?๋ต

### ๋น๋ ?ฌ์ด??๊ด๋ฆ?1. **DDD ๋ฒ์  ๊ด๋ฆ?*
   - ๊ฐ?๊ธฐ๋ฅ๋ณ??๋ฆฝ?์ธ DDD ?ฌ์ด??   - ?๋?๋ ?์ค???์ด?๋ผ??   - ?คํจ ???๋ ๋กค๋ฐฑ

2. **?์ง ๋ณด์ฆ**
   - ?จ์ ?์ค??์ปค๋ฒ๋ฆฌ์? 80%+
   - UI ?๋???์ค??   - ?ฑ๋ฅ ๋ฒค์น๋งํฌ

3. **๋ฐฐํฌ ?๋ต**
   - ?ด๋? ?์ค??๊ทธ๋ฃน
   - ๋ฒ ํ? ?๋ก๊ทธ๋จ
   - ?จ๊ณ??๋กค์??
### ๊ธฐ์  ?คํ ์งํ
1. **?์ฌ ?คํ**
   - Native Android (Java)
   - SQLite
   - Material Design

2. **๊ณํ??์ถ๊?**
   - Kotlin ๋ง์ด๊ทธ๋ ?ด์
   - Jetpack Compose UI
   - Room Database
   - Coroutines
   - Hilt DI

3. **?ด๋ผ?ฐ๋ ?ตํฉ**
   - Firebase Auth
   - Firestore
   - Cloud Functions
   - ML Kit

## ?ฏ ?ต์ฌ ?ฑ๊ณผ ์ง??(KPIs)

### ๊ธฐ์ ??์ง??- ???์ ?๊ฐ: < 2์ด?- ๋ฉ๋ชจ๋ฆ??ฌ์ฉ?? < 150MB
- ๋ฐฐํฐ๋ฆ??๋ชจ: < 5%/?๊ฐ
- ?ฌ๋?์จ: < 0.1%

### ?ฌ์ฉ??๊ฒฝํ ์ง??- ?ผ์ผ ?์ฑ ?ฌ์ฉ??(DAU): 10,000+
- ?๊ท  ?ธ์ ?๊ฐ: 15๋ถ?
- ๊ธฐ๋ฅ ?ฌ์ฉ๋ฅ? 80%+
- ???์ : 4.5+

### ๋น์ฆ?์ค ์ง??- ? ๋ฃ ?ํ?? 5%+
- ?๊ฐ ๋ฐ๋ณต ?์ต (MRR): $10,000+
- ?ฌ์ฉ???๋ ๋น์ฉ (CAC): < $5
- ?์  ๊ฐ์น?(LTV): > $50

## ?ฑ ?์ฌ ๊ตฌํ ?ํ

### ?๋ฃ??๊ธฐ๋ฅ (100%)
1. **๋ง์ค์ฝํธ ?์ค??* ??   - ?๋๊ท?๊ฐ?ฅํ ?ค์ฟผ??? ์ ์บ๋ฆญ??   - 6๊ฐ?๊ธฐ๋ฅ ?์ญ?ผ๋ก ?ค๋น๊ฒ์ด??   - 2์ด?long press๋ก?AI ?์ฑ?ธ์ ?์ฑ??
2. **?ต์ฌ ?๋ฉด** ??   - Profile: ?ฌ์ฉ???๋ก??๋ฐ??ต๊ณ
   - Checklist: ?ผ์ผ ?ด๋ ์ฒดํฌ๋ฆฌ์ค??   - Record: ?ด๋ ๊ธฐ๋ก (3๊ฐ???
   - History: ?ด๋ ?ด๋ ฅ ์กฐํ/?? 
   - Coach: AI ์ฝ์นญ ??๋ฐ?์ฑํ

3. **?ฐ์ด?ฐ๋ฒ ?ด์ค** ??   - SQLite ?์  ?ตํฉ
   - ?ด๋ ๊ธฐ๋ก ???์กฐํ/?? 
   - ?ฌ์ฉ???ต๊ณ ?๋ ?๋ฐ?ดํธ

4. **AI ๊ธฐ๋ฅ** ??   - ?์ฑ?ธ์ ?์ค??๊ตฌํ
   - AI ์ฑ๋ด ?ธํฐ?์ด??   - ?์ฐ??๋ช๋ น ์ฒ๋ฆฌ

## ? ?ค์ ?คํ

### ์ฆ์ ?์ ๊ฐ?ฅํ ?์
1. Phase 1 ?ฑ๋ฅ ์ต์ ???์
2. ?๋?๋ ?์ค???ค์??๊ตฌ์ถ
3. ?ฌ์ฉ???ผ๋๋ฐ??์ง ?์ค??๊ตฌํ

### ์ค๋น??์???์
1. iOS ๊ฐ๋ฐ ?๊ฒฝ ?ค์ 
2. ?ด๋ผ?ฐ๋ ?ธํ??๊ตฌ์ถ
3. ๋ฒ ํ? ?์ค??๋ชจ์ง

???๋ก?ํธ ๊ณํ? ?ด์  ?๋??๊ฐ๋ฐ???๋ ?ค์  ?ฑ์ ๊ธฐ๋ฅ ๊ณ ๋?์? ์ต์ข ?ํ ?์ฑ??์ด์ ??๋ง์ถ๊ณ??์ต?๋ค.

