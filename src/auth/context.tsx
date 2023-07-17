import React, {
  createContext,
  type ReactComponentElement,
  useEffect,
  useState,
} from 'react'
import { useClient } from 'react-supabase'

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
  const [state, setState] = useState(initialState)
  const client = useClient()

  useEffect(() => {
    client.auth.onAuthStateChange((event, session) => {
      setState({ session, user: session?.user })
    })
  }, [])

  return <AuthContext.Provider value={state}>{children}</AuthContext.Provider>
}
