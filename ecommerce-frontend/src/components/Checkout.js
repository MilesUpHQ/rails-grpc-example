import React, { useState } from "react";

function Checkout() {
  const local = localStorage.getItem("cartItems");
  const cartItems = local && local !== "undefined" ? JSON.parse(local) : [];
  const [shippingDetails, setShippingDetails] = useState({
    name: "",
    address: "",
    city: "",
    postalCode: "",
    country: "",
  });

  const handleInputChange = (e) => {
    setShippingDetails({ ...shippingDetails, [e.target.name]: e.target.value });
  };

  const handleSubmit = () => {
    // Handle submission logic
    console.log(
      "Proceeding to payment with shipping details:",
      shippingDetails
    );
  };

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-3xl font-bold text-center mb-6">Checkout</h1>

      <div className="flex flex-col md:flex-row gap-6">
        {/* Cart Items Summary */}
        <div className="flex-1 bg-white p-4 border rounded-md">
          <h2 className="text-2xl font-semibold mb-4">Your Cart</h2>
          <div className="divide-y divide-gray-200">
            {cartItems.map((item, index) => (
              <div
                key={index}
                className="py-2 flex justify-between items-center"
              >
                <div>
                  <p className="font-medium">{item.name}</p>
                  <p className="text-sm text-gray-600">
                    Quantity: {item.quantity}
                  </p>
                </div>
                <div>
                  <p className="text-lg font-semibold">${item.price}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Shipping Details Form */}
        <div className="flex-1 bg-white p-4 border rounded-md">
          <h2 className="text-2xl font-semibold mb-4">Shipping Details</h2>
          <div className="flex flex-col gap-2">
            <input
              className="border p-2 rounded"
              name="name"
              type="text"
              placeholder="Full Name"
              value={shippingDetails.name}
              onChange={handleInputChange}
            />
            <input
              className="border p-2 rounded"
              name="address"
              type="text"
              placeholder="Address"
              value={shippingDetails.address}
              onChange={handleInputChange}
            />
            <input
              className="border p-2 rounded"
              name="city"
              type="text"
              placeholder="City"
              value={shippingDetails.city}
              onChange={handleInputChange}
            />
            <input
              className="border p-2 rounded"
              name="postalCode"
              type="text"
              placeholder="Postal Code"
              value={shippingDetails.postalCode}
              onChange={handleInputChange}
            />
            <input
              className="border p-2 rounded"
              name="country"
              type="text"
              placeholder="Country"
              value={shippingDetails.country}
              onChange={handleInputChange}
            />
          </div>
        </div>
      </div>

      {/* Proceed to Payment Button */}
      <div className="text-center mt-6">
        <button
          onClick={handleSubmit}
          className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        >
          Proceed to Payment
        </button>
      </div>
    </div>
  );
}

export default Checkout;
