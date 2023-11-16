import React, { useEffect } from "react";
import { Link } from "react-router-dom";
import { useCart } from "../context/CartContext";

function Header() {
  const { cartItems, fetchCart } = useCart();

  return (
    <header className="bg-blue-600 text-white p-4">
      <h1 className="text-xl font-semibold">E-commerce App</h1>
      <nav className="mt-2">
        <Link to="/" className="text-white mr-4 hover:text-blue-200">
          Home
        </Link>
        <Link to="/cart" className="text-white hover:text-blue-200">
          Cart ({cartItems.length})
        </Link>
      </nav>
    </header>
  );
}

export default Header;
