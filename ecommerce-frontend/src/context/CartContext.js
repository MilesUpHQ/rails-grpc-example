import axios from "axios";
import React, { createContext, useState, useContext, useEffect } from "react";
import Cookies from "js-cookie";

const CartContext = createContext();

export const useCart = () => useContext(CartContext);

const generateGuestId = () => {
  // Generate a timestamp component
  const timestamp = new Date().getTime().toString(36);

  // Generate a random component
  const randomComponent = Math.random().toString(36).substring(2, 15);

  // Combine both components
  return `${timestamp}-${randomComponent}`;
};

const getGuestId = () => {
  let identifier = Cookies.get("guid");
  if (!identifier) {
    identifier = generateGuestId(); // Implement this function
    Cookies.set("guid", identifier, { expires: 7 });
  }
  return identifier;
};

export const CartProvider = ({ children }) => {
  const [cartItems, setCartItems] = useState([]);

  useEffect(() => {
    fetchCart();
  }, []);

  const addToCart = (product) => {
    const guestId = getGuestId();
    const existingItem = cartItems.find((item) => item.id === product.id);
    if (existingItem) {
      // Increase quantity if item already exists in cart
      setCartItems(
        cartItems.map((item) =>
          item.id === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        )
      );
    } else {
      // Add new item to cart
      setCartItems([...cartItems, { ...product, quantity: 1 }]);
    }
    // setCartItems([...cartItems, product]);
    // Make API call to add product to cart in backend
    const { id, price, quantity } = product;
    const lineItemParams = { product_id: id, price, quantity };
    axios
      .post("http://localhost:3002/orders", {
        order: {
          line_items: [lineItemParams],
          total_price: price,
        },
        guest_id: guestId,
      })
      .then((response) => {
        console.log("Product added to cart:", response.data);
      })
      .catch((error) => {
        console.error("Error adding product to cart:", error);
      });
  };

  const fetchCart = () => {
    const guestId = getGuestId();
    axios
      .get(`http://localhost:3002/orders/cart`, {
        params: { guest_id: guestId },
      })
      .then((response) => {
        // Assuming the API returns an array of cart items
        setCartItems(response.data.line_items);
      })
      .catch((error) => {
        console.error("Error fetching cart data:", error);
      });
  };

  // Update quantity of a cart item
  const setItemQuantity = (productId, quantity) => {
    if (quantity <= 0) return;
    setCartItems(
      cartItems.map((item) =>
        item.id === productId ? { ...item, quantity } : item
      )
    );
  };

  // Remove item from cart
  const removeFromCart = (productId) => {
    setCartItems(cartItems.filter((item) => item.id !== productId));
  };

  // Calculate total price of cart items
  const calculateTotal = () => {
    return cartItems
      .reduce((total, item) => total + item.price * item.quantity, 0)
      .toFixed(2);
  };

  return (
    <CartContext.Provider
      value={{
        cartItems,
        addToCart,
        setItemQuantity,
        removeFromCart,
        calculateTotal,
        getGuestId,
        fetchCart,
      }}
    >
      {children}
    </CartContext.Provider>
  );
};
