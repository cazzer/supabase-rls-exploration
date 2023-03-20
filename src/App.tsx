import React from 'react'
import { createClient } from '@supabase/supabase-js'
import { Provider } from 'react-supabase'

import { AuthProvider } from './auth/context'
import { useAuth } from './auth/hook'

import LoginView from './views/login'
import CanvasView from './views/canvas'

if (
  !process.env.REACT_APP_SUPABASE_URL ||
  !process.env.REACT_APP_SUPABASE_KEY
) {
  throw new Error(
    'REACT_APP_SUPABASE_URL and REACT_APP_SUPABASE_KEY must be set in your .env file'
  )
}

const client = createClient(
  process.env.REACT_APP_SUPABASE_URL,
  process.env.REACT_APP_SUPABASE_KEY
)

export default function App() {
  return (
    <Provider value={client}>
      <AuthProvider>
        <Root />
      </AuthProvider>
    </Provider>
  )
}

function Root() {
  const { session, user } = useAuth()

  console.log(user, session)

  if (!user) {
    return <LoginView />
  }

  return <CanvasView />
}
