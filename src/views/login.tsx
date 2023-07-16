import React, { useState } from 'react'
import { client } from '../supabase'

export default function LoginView() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const onEmailChange = (event: any) => {
    setEmail(event.target.value)
  }

  const onPasswordChange = (event: any) => {
    setPassword(event.target.value)
  }

  const onSignInClick = async (event: any) => {
    const { data, error } = await client.auth.signInWithPassword({
      email,
      password,
    })
  }

  const onSignUpClick = async (event: any) => {
    const { data, error } = await client.auth.signUp({ email, password })
    console.log(data)
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
