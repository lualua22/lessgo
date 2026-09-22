interface Props { eyebrow: string; title: string; description?: string }
export default function PageHeading({ eyebrow, title, description }: Props) {
  return <div className="mb-2 min-w-0">
    <p className="mb-2 text-[10px] font-semibold tracking-[0.18em] text-primary">{eyebrow}</p>
    <h1 className="text-[25px] font-extrabold leading-tight tracking-tight text-ink">{title}</h1>
    {description && <p className="mt-2 text-xs leading-relaxed text-ink-soft">{description}</p>}
  </div>
}
