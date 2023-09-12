import React from 'react'
import { Provider } from 'react-supabase'

import { AuthProvider } from './auth/context'
import { useAuth } from './auth/hook'
import { client } from './supabase'

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
  const { user } = useAuth()

  if (!user) {
    return <LoginView />
  }

  return <CanvasView />
}
