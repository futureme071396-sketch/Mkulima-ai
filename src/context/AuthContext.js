'use client'; // needed if using Next.js App Router (Next 13+)

import { createContext, useContext, useState } from 'react';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState({
    name: 'Admin',
    role: 'Administrator',
  });

  function logout() {
    console.log('User logged out');
    setUser(null);
  }

  return (
    <AuthContext.Provider value={{ user, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}