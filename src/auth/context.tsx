import React, {
  createContext,
  type ReactComponentElement,
  useEffect,
  useState,
} from 'react'
import { useAuthStateChange, useClient } from 'react-supabase'

const initialState: {
  session: any
  user: any
} = { session: null, user: null }
export const AuthContext = createContext(initialState)

export function AuthProvider({
  children,
}: {
  children: ReactComponentElement<any>
}) {
  const client = useClient()
  const [state, setState] = useState(initialState)

  useEffect(() => {
    const session = client.auth.session()
    setState({ session, user: session?.user ?? null })
  }, [])

  useAuthStateChange((event, session) => {
    console.log(`Supabase auth event: ${event}`, session)
    setState({ session, user: session?.user ?? null })
  })

  return <AuthContext.Provider value={state}>{children}</AuthContext.Provider>
}
