import React from "react";

function Checkout() {
  return (
    <div className="p-4">
      <h2 className="text-2xl font-bold mb-4">Checkout</h2>
      <form>
        {/* Checkout form fields go here */}
        <button className="bg-blue-600 text-white px-4 py-2 mt-4 hover:bg-blue-700">
          Place Order
        </button>
      </form>
    </div>
  );
}

export default Checkout;
