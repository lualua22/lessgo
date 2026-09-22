# LessGo

친구들과 함께 스마트폰 사용 시간을 줄이는 챌린지 앱입니다. 매일 스크린타임을 인증하고, 개인 또는 그룹 챌린지에서 목표 달성률을 비교할 수 있습니다.

## 주요 기능

- 전화번호와 비밀번호를 이용한 회원가입 및 로그인
- Google, Kakao 소셜 로그인
- 개인 및 그룹 스마트폰 사용 시간 챌린지 생성과 참가
- iOS 스크린타임 또는 Android 디지털 웰빙 화면 사진 인증
- Gemini Vision을 이용한 인증 사진 진위 및 사용 시간 분석
- 일별 인증 기록과 사용 시간 통계
- 챌린지 참가자 순위, 팀, 목표 앱 제한
- 인증 보상으로 받는 캐시와 배지 상점
- Toss Payments 기반 프리미엄 결제
- 피드백 제출 및 관리자 화면
- Vite PWA와 Capacitor 기반 Android/iOS 앱 설정

## 화면 구성

- `/landing`: 서비스 소개
- `/welcome`: 로그인 방식 선택
- `/login`: 전화번호 로그인
- `/signup`: 회원가입
- `/home`: 로그인 후 홈 화면
- `/verify`: 스크린타임 인증
- `/challenges`: 내 챌린지 목록
- `/challenges/new`: 새 챌린지 생성
- `/challenges/:id`: 챌린지 상세 및 참가자 화면
- `/stats`: 사용 시간 통계
- `/me`: 내 프로필과 배지
- `/feedback`: 피드백 작성
- `/settings`: 설정
- `/premium`: 프리미엄 결제
- `/admin`: 관리자 화면

로그인하지 않은 사용자는 인증이 필요한 화면에 접근하면 `/welcome`으로 이동합니다.

## 기술 구성

### 프런트엔드

- React 18
- TypeScript
- Vite
- React Router
- Tailwind CSS
- Recharts
- Vite PWA
- Pretendard 폰트

### 백엔드

- Node.js
- Express
- PostgreSQL
- `pg` 데이터베이스 클라이언트
- `bcryptjs` 비밀번호 해시
- Gemini API 이미지 분석
- Toss Payments 결제 승인

### 모바일

- Capacitor Android
- Capacitor iOS
- 앱 ID: `com.lessgo.app`

## 실행 환경

필요한 프로그램:

- Node.js
- npm
- PostgreSQL 또는 Supabase 프로젝트

의존성 설치:

```bash
npm install
```

## 환경 변수

루트의 `.env.example`을 참고해 `.env` 파일을 만들고 실제 값을 입력합니다. `.env`는 비밀값을 포함하므로 커밋하지 않습니다.

### 백엔드 변수

| 이름 | 용도 | 필수 여부 |
| --- | --- | --- |
| `DATABASE_URL` | PostgreSQL 또는 Supabase 연결 주소 | 필수 |
| `PORT` | Express 서버 포트. 기본값은 `4000` | 선택 |
| `ADMIN_PASSWORD` | 관리자 페이지 Basic Auth 비밀번호 | 관리자 기능 사용 시 필요 |
| `GEMINI_API_KEY` | 스크린타임 사진 분석 | 인증 분석 사용 시 필요 |
| `TOSS_SECRET_KEY` | Toss 결제 승인용 서버 키 | 실제 결제 사용 시 필요 |

### 프런트엔드 변수

Vite에서 읽는 변수는 반드시 `VITE_` 접두사를 사용합니다.

| 이름 | 용도 | 필수 여부 |
| --- | --- | --- |
| `VITE_API_URL` | API 주소. 기본값은 `http://localhost:4000/api` | 배포 시 권장 |
| `VITE_GOOGLE_CLIENT_ID` | Google 로그인 클라이언트 ID | Google 로그인 사용 시 필요 |
| `VITE_KAKAO_JS_KEY` | Kakao JavaScript 키 | Kakao 로그인 사용 시 필요 |
| `VITE_TOSS_CLIENT_KEY` | Toss 결제 위젯 클라이언트 키 | 결제 사용 시 필요 |

키의 실제 값은 README나 소스 코드에 기록하지 않습니다.

## 데이터베이스 초기화

`DATABASE_URL`을 설정한 뒤 아래 명령으로 테이블과 인덱스를 생성합니다.

```bash
node server/migrate.js
```

스키마는 [server/schema.sql](server/schema.sql)에 있습니다. 주요 테이블은 다음과 같습니다.

- `users`: 사용자 계정, 프로필, 캐시, 배지
- `challenges`: 챌린지와 참가자 정보
- `verifications`: 날짜별 스크린타임 인증
- `feedback`: 사용자 피드백
- `payments`: 프리미엄 결제 기록
- `logs`: 서비스 이벤트 로그

## 로컬 실행

프런트엔드와 백엔드를 함께 실행합니다.

```bash
npm run dev:all
```

접속 주소:

- 웹 앱: http://localhost:5173
- API: http://localhost:4000
- API 상태 확인: http://localhost:4000/api/health

프런트엔드만 실행하려면:

```bash
npm run dev
```

백엔드만 실행하려면:

```bash
npm run server
```

## 검증 명령

TypeScript 검사와 프로덕션 빌드:

```bash
npm run build
```

ESLint 실행:

```bash
npm run lint
```

빌드 결과 미리보기:

```bash
npm run preview
```

## API 구조

Express 서버는 `/api` 아래에 기능별 라우터를 등록합니다.

- `/api/auth`: 회원가입, 로그인, 소셜 로그인, 프로필
- `/api/challenges`: 챌린지 생성, 조회, 참가, 수정, 삭제
- `/api/verify`: 이미지 분석과 자동화 인증
- `/api/verifications`: 인증 기록 조회
- `/api/shop`: 캐시와 배지 상점
- `/api/payments`: 프리미엄 주문과 결제 승인
- `/api/feedback`: 피드백
- `/api/admin`: 관리자 기능

## 인증 방식

로그인 후 사용자별 API 키를 발급하고 인증이 필요한 요청에 사용합니다. 서버는 사용자 비밀번호를 평문으로 저장하지 않고 `bcrypt` 해시로 저장합니다.

관리자 화면과 관리자 API는 `ADMIN_PASSWORD`를 이용한 Basic Auth로 보호합니다.

## 이미지 인증 흐름

1. 사용자가 스크린타임 또는 디지털 웰빙 이미지를 업로드합니다.
2. 서버가 Gemini API로 실제 시스템 화면인지 확인합니다.
3. 오늘 날짜, 전체 사용 시간, 추적 앱별 사용 시간을 분석합니다.
4. 분석 결과가 유효하면 해당 날짜의 인증 기록을 저장합니다.
5. 첫 인증이면 사용자에게 보상 캐시를 지급합니다.

`/api/verify/quick`은 iOS 단축어에서 multipart 이미지 또는 원본 이미지 바이트를 직접 보내는 자동화용 엔드포인트입니다.

## 배포 참고

- Vercel은 프런트엔드 배포에 사용하도록 `vercel.json`에서 모든 경로를 `index.html`로 연결합니다.
- Express API는 별도 Node.js 호스팅 환경에서 실행해야 합니다.
- 배포 환경의 `VITE_API_URL`은 실제 API 주소로 설정해야 합니다.
- Supabase/PostgreSQL의 연결 주소와 Gemini, OAuth, Toss 키는 배포 플랫폼의 환경 변수에 등록합니다.
- Capacitor 설정은 현재 `https://lessgo-mu.vercel.app`을 앱의 웹 서버 주소로 사용합니다.

## 프로젝트 구조

```text
src/                 React 앱, 페이지, 컴포넌트, 상태 관리
server/              Express API, 라우터, DB 접근, 마이그레이션
public/              정적 이미지와 앱 아이콘
android/             Capacitor Android 프로젝트
ios/                 Capacitor iOS 프로젝트
desktop/             데스크톱 실행 설정
capacitor.config.ts  Capacitor 설정
vite.config.ts       Vite 및 PWA 설정
server/schema.sql    PostgreSQL 스키마
.env.example         환경 변수 예시
```

## 현재 확인된 실행 상태

- Node.js와 npm 설치 완료
- npm 의존성 설치 완료
- `npm run build` 성공
- 로컬 웹 서버와 API 서버 실행 확인
- `GET /api/health` 응답 확인