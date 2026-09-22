import type { ButtonHTMLAttributes } from 'react'
import { useGoogleLogin } from '@react-oauth/google'

type Props = Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'onError'> & {
  onToken: (token: string) => void
  onError: () => void
}

function ConfiguredGoogleButton({ onToken, onError, ...props }: Props) {
  const login = useGoogleLogin({
    flow: 'implicit',
    onSuccess: (response) => onToken(response.access_token),
    onError,
  })
  return <button {...props} onClick={() => login()} />
}

export default function GoogleAuthButton(props: Props) {
  if (import.meta.env.VITE_GOOGLE_CLIENT_ID?.trim()) {
    return <ConfiguredGoogleButton {...props} />
  }
  const { onToken, onError, ...buttonProps } = props
  return (
    <>
      <button {...buttonProps} disabled />
      <p className="mt-2 text-center text-xs text-ink-soft">
        Google 로그인이 아직 준비되지 않았어요.
      </p>
    </>
  )
}
