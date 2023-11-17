// src/apiUrls.js

const PRODUCT_BASE_URL = "http://localhost:3001";
const ORDER_BASE_URL = "http://localhost:3002";

export const API_URLS = {
  LIST_PRODUCTS: `${PRODUCT_BASE_URL}/products`,
  FETCH_PRODUCT: (productId) => `${PRODUCT_BASE_URL}/products/${productId}`,
  ADD_TO_CART: `${ORDER_BASE_URL}/orders`,
  FETCH_CART: `${ORDER_BASE_URL}/orders/cart`,
  UPDATE_CART_ITEM: (orderId) => `${ORDER_BASE_URL}/orders/${orderId}`,
  REMOVE_CART_ITEM: (lineItemId) =>
    `${ORDER_BASE_URL}/orders/remove/${lineItemId}`,
  // Add more API endpoints as needed
};

export default API_URLS;
