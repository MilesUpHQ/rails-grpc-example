// src/components/Cart.js

import React from "react";
import { useCart } from "../context/CartContext";

function Cart() {
  const { cartItems, setItemQuantity, orderTotal } = useCart(); // Assume these functions are implemented in your context

  const subtotal = orderTotal.toFixed(2); // Assuming this calculates the subtotal
  const total = subtotal; // Modify this as needed, e.g., add shipping or taxes

  // Handler for quantity change
  const handleQuantityChange = (item, newQuantity) => {
    setItemQuantity(item, newQuantity);
  };

  return (
    <div className="max-w-7xl mx-auto p-4">
      <h2 className="text-2xl font-bold mb-4 text-center">Your Cart</h2>

      <div className="flex flex-col md:flex-row gap-4">
        {/* Left Column: Line Item Details */}
        <div className="flex-1">
          {cartItems.map((item, index) => (
            <div
              key={index}
              className="flex items-center justify-between border-b mb-4 pb-4"
            >
              <img
                src={item.image_urls ? item.image_urls[0] : ""}
                alt={item.name}
                className="w-20 h-20 object-cover mr-4"
              />
              {/* <div className="flex-1 mr-4"> */}
              <h5 className="text-lg font-bold">{item.name}</h5>
              <p>Price: ${item.price}</p>
              {/* </div> */}
              {/* Quantity Dropdown */}
              <select
                className="border p-2 mr-2"
                value={item.quantity}
                onChange={(e) =>
                  handleQuantityChange(item, parseInt(e.target.value))
                }
              >
                {[1, 2, 3, 4, 5].map((qty) => (
                  <option key={qty} value={qty}>
                    {qty}
                  </option>
                ))}
              </select>
              {/* Remove Button */}
              <button className="bg-white hover:bg-gray-200 text-gray-800 font-semibold py-2 px-4 border border-gray-400 rounded">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  strokeWidth={1.5}
                  stroke="currentColor"
                  className="w-6 h-6"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0"
                  />
                </svg>
              </button>
            </div>
          ))}
        </div>

        {/* Right Column: Subtotal, Total, and Checkout */}
        <div className="flex-2">
          <div className="sticky top-4 bg-white p-4 border rounded-lg">
            <div className="pb-20">
              <input
                type="text"
                className="border p-2 w-full mb-2"
                placeholder="Discount Code"
              />
              <button className="bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 rounded-full shadow w-full">
                Apply
              </button>
            </div>
            <p className="text-lg mb-2">
              <b>Subtotal:</b> ${total}
            </p>
            <p className="text-lg mb-4">
              <b>Total:</b> ${total}
            </p>
            <button className="bg-blue-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-full w-full mb-4">
              Checkout
            </button>
            {/* Additional Form (e.g., Discount Code) */}
          </div>
        </div>
      </div>
    </div>
  );
}

export default Cart;
