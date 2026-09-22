import { Link } from 'react-router-dom'
import { useStore } from '../state/store'
import { achievementRate, currentStreak, isSuccess } from '../lib/stats'
import { addDays, todayISO, weekdayKr, minutesToLabel } from '../lib/date'
import { usePersonalChallenge } from '../lib/usePersonalChallenge'
import { DAILY_VERIFY_CASH } from '../state/badges'
import Avatar from '../components/Avatar'
import { ChevronRightIcon, FlagIcon, SettingsIcon } from '../components/icons'

export default function Home() {
  const { profile, records, todayRecord } = useStore()
  const { challenges, personalChallenge } = usePersonalChallenge()
  const goal = personalChallenge ? { dailyLimitMinutes: personalChallenge.goalMinutes } : null
  const streak = goal ? currentStreak(records, goal) : 0
  const rate = goal ? achievementRate(records, goal, 7) : 0
  const today = todayISO()
  const days = Array.from({ length: 7 }, (_, i) => addDays(today, i - 6))
  const other = challenges?.filter(c => c.id !== personalChallenge?.id) ?? []
  const verified = todayRecord.verified
  const success = goal && isSuccess(todayRecord, goal)

  return (
    <div className="home-page px-6 pb-7 pt-5">
      <div className="flex items-center justify-between gap-3">
        <div>
          <p className="text-xs text-ink-soft">{new Date().getMonth() + 1}월 {new Date().getDate()}일 {weekdayKr(today)}요일</p>
          <h1 className="mt-2 text-[25px] font-bold leading-[1.4] tracking-tight">{profile.name || '친구'}님,<br />오늘의 나를 넘어선다.</h1>
        </div>
        <Link to="/me" aria-label="내 프로필 보기" className="rounded-full border-4 border-line shadow-card">
          <Avatar src={profile.avatar} emoji={profile.emoji} size={52} />
        </Link>
      </div>

      <section className="focus-card relative mt-6 overflow-hidden rounded-[22px] p-6 text-white">
        <div className="relative z-10 flex items-center justify-between">
          <span className="rounded-full border border-white/25 px-3 py-1 text-[11px] tracking-wide">DAILY COMMITMENT</span>
          {personalChallenge && <Link aria-label="개인 챌린지 보기" to={`/challenges/${personalChallenge.id}`} className="rounded-full bg-white/10 p-2"><SettingsIcon className="h-4 w-4" /></Link>}
        </div>
        <div className="relative z-10 mt-6 max-w-[75%]">
          <p className="text-xs text-white/75">{personalChallenge ? personalChallenge.title : '미래의 나를 위한 첫 번째 다짐'}</p>
          <h2 className="mt-2 text-[30px] font-extrabold leading-[1.35] tracking-tight">
            {personalChallenge ? <span className="text-[44px] tabular-nums text-primary-light">{minutesToLabel(personalChallenge.goalMinutes)}</span> : <>몰입은 깊게.<br />가능성은 더 높게.</>}
          </h2>
          <p className="mt-2 text-xs leading-relaxed text-white/75">{personalChallenge ? verified ? success ? '오늘도 이겨냈다. 목표 달성 완료.' : '오늘의 기록을 발판으로, 내일 다시.' : '하루 스크린타임 목표' : '목표를 정하고, 숫자로 변화를 확인하세요.'}</p>
        </div>
        <div aria-hidden className="orbit-art"></div>
        <Link to={personalChallenge ? verified ? '/stats' : '/verify' : '/challenges/new'} className="relative z-10 mt-7 flex min-h-12 items-center justify-between primary-action px-4 py-3 text-sm transition-transform active:scale-[0.98]">
          {personalChallenge ? verified ? '오늘의 기록 보기' : '오늘 스크린타임 인증하기' : '나의 첫 목표 설정하기'}<ChevronRightIcon className="h-4 w-4" />
        </Link>
        <p className="relative z-10 mt-3 text-center text-[11px] text-white/75">{verified ? `오늘 사용 시간 · ${minutesToLabel(todayRecord.usedMinutes ?? 0)}` : `하루 한 번 인증하고 ${DAILY_VERIFY_CASH} 캐시 받기`}</p>
      </section>

      <section className="mt-7">
        <div className="mb-4 flex items-center justify-between"><h2 className="text-base font-bold">최근 7일의 몰입</h2><Link to="/stats" className="flex items-center gap-1 text-xs text-ink-soft">기록 보기<ChevronRightIcon className="h-3 w-3" /></Link></div>
        <div className="rounded-[20px] border border-line bg-surface p-4">
          <div className="grid grid-cols-7 gap-2">
            {days.map(date => {
              const record = records.find(r => r.date === date)
              const done = record?.verified
              return <div key={date} className="flex flex-col items-center gap-2">
                <span className={`text-[11px] ${date === today ? 'font-bold text-primary' : 'text-ink-faint'}`}>{weekdayKr(date)}</span>
                <span aria-label={`${date}: ${done ? '인증 완료' : '미인증'}`} className={`flex aspect-square w-full items-center justify-center rounded-full text-sm ${done ? 'bg-primary text-white' : date === today ? 'border border-primary bg-primary-tint text-primary' : 'bg-bg text-ink-faint'}`}>{done ? '✓' : date === today ? '오늘' : '·'}</span>
              </div>
            })}
          </div>
          <div className="mt-5 grid grid-cols-2 divide-x divide-line border-t border-line pt-4 text-center">
            <div><p className="text-[11px] text-ink-soft">연속 목표 달성</p><p className="mt-1 text-xl font-bold">{streak}<span className="ml-1 text-xs font-normal text-ink-soft">일</span></p></div>
            <div><p className="text-[11px] text-ink-soft">최근 7회 달성률</p><p className="mt-1 text-xl font-bold">{rate}<span className="ml-1 text-xs font-normal text-ink-soft">%</span></p></div>
          </div>
        </div>
      </section>

      <section className="mt-7">
        <h2 className="mb-3 text-base font-bold">같은 목표, 더 강한 동기</h2>
        <Link to={other.length ? '/challenges' : '/challenges/new'} className="flex items-center gap-3 rounded-[20px] border border-line bg-surface p-5 transition-transform active:scale-[0.98]">
          <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-primary-tint text-primary"><FlagIcon className="h-6 w-6" /></span>
          <span className="min-w-0 flex-1"><span className="block text-sm font-bold">{other.length ? `함께하는 챌린지 ${other.length}개` : '함께 도전할 친구 찾기'}</span><span className="mt-1 block truncate text-xs text-ink-soft">{other.length ? other[0].title : '친구와 챌린지를 만들고 끝까지 함께해요'}</span></span>
          <ChevronRightIcon className="h-4 w-4 shrink-0 text-ink-soft" />
        </Link>
      </section>
      <Link to="/me" className="mt-4 flex items-center justify-between rounded-2xl border border-line px-4 py-3 text-xs"><span className="text-ink-soft">작은 실천으로 모은 캐시</span><span className="font-bold">{profile.cash.toLocaleString()} C <span className="ml-1 text-ink-faint">→</span></span></Link>
      <p className="mt-6 text-center text-[10px] tracking-[0.16em] text-ink-faint">FOCUS TODAY. OWN TOMORROW.</p>
    </div>
  )
}
