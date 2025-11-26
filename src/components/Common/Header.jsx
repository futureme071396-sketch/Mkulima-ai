'use client'

import { useAuth } from "../../context/AuthContext";
import { Menu } from "lucide-react";

export default function Header({ onMenuToggle }) {
  const auth = useAuth() || {};
  const user = auth.user;
  const logout = auth.logout;

  return (
    <header className="bg-white shadow-sm border-b border-gray-200 px-6 py-4 flex items-center justify-between">
      {/* Mobile Menu Button */}
      <button
        className="lg:hidden text-gray-700"
        onClick={onMenuToggle}
      >
        <Menu size={26} />
      </button>

      {/* Title */}
      <h1 className="text-2xl font-semibold text-gray-900">
        Mkulima AI Dashboard
      </h1>

      {/* User Section */}
      <div className="flex items-center space-x-4">
        <span className="text-gray-700 text-sm">
          {user ? `Logged in as ${user.name || "User"}` : "Not logged in"}
        </span>

        {logout && (
          <button
            className="px-4 py-2 rounded-lg bg-red-500 text-white text-sm"
            onClick={logout}
          >
            Logout
          </button>
        )}
      </div>
    </header>
  );
}
