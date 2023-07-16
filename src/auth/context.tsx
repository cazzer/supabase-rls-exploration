import React, {
  createContext,
  type ReactComponentElement,
  useEffect,
  useState,
} from 'react'

import { client } from '../supabase'

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

  useEffect(() => {
    async function getSession() {
      const { data, error } = await client.auth.getSession()
      console.log(data)
      setState({ session: data, user: null })
    }

    getSession().catch(console.error)
  }, [])

  return <AuthContext.Provider value={state}>{children}</AuthContext.Provider>
}
