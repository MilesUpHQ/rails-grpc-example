import axios from "axios";
import Cookies from "js-cookie";

const generateGuestId = () => {
  const timestamp = new Date().getTime().toString(36);
  const randomComponent = Math.random().toString(36).substring(2, 15);
  return `${timestamp}-${randomComponent}`;
};

const getGuestId = () => {
  let identifier = Cookies.get("guid");
  if (!identifier) {
    identifier = generateGuestId();
    Cookies.set("guid", identifier, { expires: 7 });
  }
  return identifier;
};

const fetchCart = async () => {
  try {
    const guestId = getGuestId();
    const response = await axios.get(`http://localhost:3002/orders/cart`, {
      params: { guest_id: guestId },
    });
    localStorage.setItem("cartItems", JSON.stringify(response.data.line_items));
    return response.data.line_items;
  } catch (error) {
    console.error("Error fetching cart data:", error);
  }
};

const addToCart = async (product) => {
  const guestId = getGuestId();
  try {
    const response = await axios.post("http://localhost:3002/orders", {
      order: {
        line_items: [
          {
            product_id: product.id,
            price: product.price,
            quantity: product.quantity,
          },
        ],
        total_price: product.price,
      },
      guest_id: guestId,
    });
    // Update localStorage with the new cart data
    localStorage.setItem(
      "cartItems",
      JSON.stringify(response.data.updatedCartItems)
    );
  } catch (error) {
    console.error("Error adding product to cart:", error);
  }
};

const removeFromCart = async (productId) => {
  const guestId = getGuestId();
  const cartItems = JSON.parse(localStorage.getItem("cartItems"));
  const lineItem = cartItems.filter(
    (item) => item.product_id === parseInt(productId)
  )[0];

  if (!lineItem) {
    console.error("Item not found in cart");
    return;
  }

  try {
    const response = await axios.delete(
      `http://localhost:3002/orders/remove/${lineItem.id}`,
      {
        params: { guest_id: guestId, order_id: lineItem.order_id },
      }
    );
    // Update localStorage with the new cart data
    localStorage.setItem(
      "cartItems",
      JSON.stringify(response.data.updatedCartItems)
    );
  } catch (error) {
    console.error("Error removing item from cart:", error);
  }
};

const setItemQuantity = async (lineItem, newQuantity) => {
  const guestId = getGuestId();
  try {
    const response = await axios.put(
      `http://localhost:3002/orders/${lineItem.order_id}`,
      {
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
      }
    );
    // Update localStorage with the new cart data
    localStorage.setItem(
      "cartItems",
      JSON.stringify(response.data.updatedCartItems)
    );
  } catch (error) {
    console.error("Error updating item quantity:", error);
  }
};

export { fetchCart, addToCart, removeFromCart, setItemQuantity, getGuestId };
