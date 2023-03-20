import React, { useState } from 'react'
import { useSignIn, useSignUp } from 'react-supabase'

export default function LoginView() {
  const [signInResult, signIn] = useSignIn()
  const [signUpResult, signUp] = useSignUp()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const onEmailChange = (event: any) => {
    setEmail(event.target.value)
  }

  const onPasswordChange = (event: any) => {
    setPassword(event.target.value)
  }

  const onSignInClick = (event: any) => {
    signIn({ email, password })
  }

  const onSignUpClick = (event: any) => {
    signUp({ email, password })
  }

  return (
    <form>
      <input
        type="text"
        placeholder="email"
        value={email}
        onChange={onEmailChange}
      />
      <input
        type="password"
        placeholder="password"
        value={password}
        onChange={onPasswordChange}
      />
      <div>
        <button type="button" onClick={onSignInClick}>
          Sign In
        </button>
        <button type="button" onClick={onSignUpClick}>
          Sign Up
        </button>
      </div>
    </form>
  )
}
