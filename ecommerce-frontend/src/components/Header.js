import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { fetchCart } from "../utils/cartHelpers";

function Header() {
  const [cartCount, setCartCount] = useState(0);

  useEffect(() => {
    const updateCartCount = () => {
      const cartItems = localStorage.getItem("cartItems");
      setCartCount(JSON.parse(cartItems).length);
    };

    updateCartCount();

    // Optional: Add event listener for cart updates if needed
    // window.addEventListener("cartUpdated", updateCartCount);
    // return () => window.removeEventListener("cartUpdated", updateCartCount);
  }, []);

  return (
    <header className="bg-blue-600 text-white p-4">
      <h1 className="text-xl font-semibold">E-commerce App</h1>
      <nav className="mt-2">
        <Link to="/" className="text-white mr-4 hover:text-blue-200">
          Home
        </Link>
        <Link to="/cart" className="text-white hover:text-blue-200">
          Cart ({cartCount})
        </Link>
      </nav>
    </header>
  );
}

export default Header;
