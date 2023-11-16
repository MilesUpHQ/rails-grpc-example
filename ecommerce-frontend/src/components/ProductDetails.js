// src/components/ProductDetails.js

import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import axios from "axios";
import { addToCart, removeFromCart, fetchCart } from "../utils/cartHelpers";

function ProductDetails() {
  const [product, setProduct] = useState(null);
  const [quantity, setQuantity] = useState(1);
  const { productId } = useParams();
  const [isLoading, setIsLoading] = useState(true);
  const [isInCart, setIsInCart] = useState(false);
  const [lineItem, setLineItem] = useState({});

  useEffect(() => {
    setIsLoading(true);
    axios
      .get(`http://localhost:3001/products/${productId}`)
      .then((response) => {
        setProduct(response.data);
      })
      .catch((error) => {
        console.error("Error fetching product:", error);
      })
      .finally(() => {
        setIsLoading(false);
      });
  }, [productId]);

  useEffect(() => {
    checkIfProductInCart();
  }, []);

  const checkIfProductInCart = async () => {
    const cartItems = await fetchCart();
    setIsInCart(
      cartItems.some((item) => item.product_id === parseInt(productId))
    );
  };

  const handleCartAction = async () => {
    if (isInCart) {
      removeFromCart(productId);
    } else {
      addToCart({ ...product, quantity });
    }
    await checkIfProductInCart();
  };

  const handleQuantityChange = (increment) => {
    setQuantity((prev) => (increment ? prev + 1 : prev > 1 ? prev - 1 : prev));
  };

  if (isLoading) return <div>Loading...</div>;
  if (!product) return <div>Product not found.</div>;

  return (
    <div className="flex flex-col md:flex-row p-4">
      {product && (
        <>
          {/* Image Column */}
          <div className="flex-1">
            <img
              src={product.image_urls[0]}
              alt={product.name}
              className="w-full h-full object-cover"
            />
          </div>

          {/* Details Column */}
          <div className="flex-1 ml-4">
            <h2 className="text-2xl font-bold mb-4">{product.name}</h2>
            <p className="text-lg font-semibold mb-2">${product.price}</p>
            <div className="flex items-center mb-4">
              <button
                onClick={() => handleQuantityChange(false)}
                className="px-2 py-1 border"
              >
                -
              </button>
              <input
                type="text"
                value={quantity}
                readOnly
                className="mx-2 border text-center w-12"
              />
              <button
                onClick={() => handleQuantityChange(true)}
                className="px-2 py-1 border"
              >
                +
              </button>
            </div>
            <button
              className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mb-4"
              onClick={handleCartAction}
            >
              {isInCart ? "Remove" : "Add to Cart"}
            </button>
            <p>{product.description}</p>
          </div>
        </>
      )}
    </div>
  );
}

export default ProductDetails;
