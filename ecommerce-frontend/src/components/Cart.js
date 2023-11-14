// src/components/Cart.js

import React, { useEffect, useState } from "react";
import { useCart } from "../context/CartContext";
import axios from "axios";

function Cart() {
  const { cartItems, setItemQuantity, fetchCart } = useCart(); // Assume these functions are implemented in your context
  // const [isLoading, setIsLoading] = useState(true);
  // const [error, setError] = useState(null);

  useEffect(() => {
    fetchCart();
  }, [fetchCart]);

  // if (isLoading) return <div>Loading...</div>;
  // if (error) return <div>{error}</div>;

  return (
    <div className="p-4 flex flex-col md:flex-row">
      {/* Left Section: Line Items */}
      <div className="flex-1">
        {cartItems.map((item, index) => (
          <div key={index} className="flex justify-between items-center mb-4">
            <div>
              <h5 className="text-lg font-bold">{item.name}</h5>
              <p>${item.price}</p>
            </div>
            <select
              value={item.quantity}
              onChange={(e) =>
                setItemQuantity(index, parseInt(e.target.value, 10))
              }
              className="border p-2 rounded"
            >
              {[1, 2, 3, 4, 5].map(
                (
                  qty // Assume a max quantity of 5 for demo
                ) => (
                  <option key={qty} value={qty}>
                    {qty}
                  </option>
                )
              )}
            </select>
          </div>
        ))}
      </div>

      {/* Right Section: Total Amount */}
      <div className="flex-1 mt-4 md:mt-0 md:ml-4">
        <h4 className="text-xl font-bold mb-2">Total</h4>
        <p>
          $
          {cartItems
            .reduce((total, item) => total + item.price * item.quantity, 0)
            .toFixed(2)}
        </p>
      </div>
    </div>
  );
}

export default Cart;
