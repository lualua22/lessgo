import { Link } from 'react-router-dom'

export default function Welcome() {
  return (
    <div className="flex min-h-full flex-col px-7 pb-8 pt-12">
      <div className="flex items-center gap-2 text-sm font-bold"><span className="flex h-8 w-8 items-center justify-center rounded-xl bg-primary text-white">L</span>LessGo</div>
      <div className="flex flex-1 flex-col justify-center py-10">
        <p className="text-[11px] tracking-[0.2em] text-primary">FOCUS. DISCIPLINE. GROWTH.</p>
        <h1 className="mt-5 text-[36px] font-bold leading-[1.35] tracking-tight">오늘의 몰입이<br />내일의 나를 만든다.</h1>
        <p className="mt-5 text-sm leading-7 text-ink-soft">스크린타임은 줄이고, 가능성은 높이고.<br />목표와 기록으로 증명하는 나의 성장.</p>
        <div aria-hidden className="growth-art mt-9 h-48 overflow-hidden rounded-[22px] border border-line">
          <svg viewBox="0 0 340 190" fill="none">
            <path d="M25 150H315M25 110H315M25 70H315M75 30V170M145 30V170M215 30V170M285 30V170" stroke="#273341" strokeDasharray="3 7" />
            <path d="M25 153C70 153 73 129 110 130S158 116 188 91S242 101 284 47L314 25" stroke="#4FB9FF" strokeWidth="3" />
            <circle cx="284" cy="47" r="15" fill="#4FB9FF" fillOpacity=".12" /><circle cx="284" cy="47" r="4" fill="#8FE0FF" />
          </svg>
          <span className="absolute bottom-4 right-5 text-[10px] tracking-widest text-primary-ink">YOUR NEXT LEVEL STARTS HERE.</span>
        </div>
      </div>
      <div className="space-y-3">
        <Link to="/signup" className="flex min-h-[52px] items-center justify-center primary-action px-5 text-sm transition-transform active:scale-[0.98]">나의 첫 다짐 시작하기</Link>
        <Link to="/login" className="flex min-h-12 items-center justify-center rounded-2xl text-sm text-ink-soft">이미 계정이 있어요 <span className="ml-2 font-bold text-primary">로그인</span></Link>
      </div>
    </div>
  )
}
