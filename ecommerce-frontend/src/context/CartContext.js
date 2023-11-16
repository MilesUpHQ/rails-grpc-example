import axios from "axios";
import React, { createContext, useState, useContext, useEffect } from "react";
import Cookies from "js-cookie";

const CartContext = createContext();

export const useCart = () => useContext(CartContext);

const generateGuestId = () => {
  const timestamp = new Date().getTime().toString(36);

  const randomComponent = Math.random().toString(36).substring(2, 15);
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
  const [orderId, setOrderId] = useState(null);
  const [orderTotal, setOrderTotal] = useState(0);

  useEffect(() => {
    calculateTotal();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cartItems]);

  // Calculate total price of cart items
  const calculateTotal = () => {
    const newTotal = cartItems.reduce(
      (acc, item) => acc + item.price * item.quantity,
      0
    );
    setOrderTotal(newTotal);
  };

  const addToCart = (product) => {
    const guestId = getGuestId();
    const existingItem = cartItems.find((item) => item.id === product.id);

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
        setOrderId(response.data.id);
      })
      .catch((error) => {
        console.error("Error fetching cart data:", error);
      });
  };

  // Update quantity of a cart item
  const setItemQuantity = (lineItem, newQuantity) => {
    if (newQuantity <= 0) return;

    const guestId = getGuestId();
    const updatedItems = cartItems.map((item) =>
      item.id === lineItem.id ? { ...item, quantity: newQuantity } : item
    );

    // Update the backend
    axios
      .put(`http://localhost:3002/orders/${orderId}`, {
        guest_id: guestId,
        order: {
          line_items_attributes: [
            {
              id: lineItem.id,
              product_id: lineItem.product_id,
              quantity: newQuantity,
            },
          ],
        },
      })
      .then((response) => {
        // Update local state only after successful backend update
        setCartItems(updatedItems);
      })
      .catch((error) => {
        console.error("Error updating item quantity:", error);
      });
  };

  // Remove item from cart
  const removeFromCart = (lineItem) => {
    const guestId = getGuestId(); // Assuming you have a guest ID or similar identifier

    // API call to remove the item
    axios
      .delete(`http://localhost:3002/orders/remove/${lineItem.id}`, {
        params: { guest_id: guestId, order_id: lineItem.order_id },
      })
      .then((response) => {
        // Update local state with the updated cart items
        const updatedCartItems = cartItems.filter(
          (item) => item.id !== lineItem.id
        );
        setCartItems(updatedCartItems); // Adjust according to your API response
      })
      .catch((error) => {
        console.error("Error removing item from cart:", error);
      });
  };

  return (
    <CartContext.Provider
      value={{
        cartItems,
        addToCart,
        setItemQuantity,
        removeFromCart,
        orderTotal,
        getGuestId,
        fetchCart,
      }}
    >
      {children}
    </CartContext.Provider>
  );
};
