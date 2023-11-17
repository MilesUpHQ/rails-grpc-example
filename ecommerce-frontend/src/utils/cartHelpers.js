import axios from "axios";
import Cookies from "js-cookie";
import API_URLS from "./apiUrls";

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
    const response = await axios.get(API_URLS.FETCH_CART, {
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
    const response = await axios.post(API_URLS.ADD_TO_CART, {
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

const removeFromCart = async (product) => {
  const guestId = getGuestId();
  const local = localStorage.getItem("cartItems");
  const cartItems = local && local !== "undefined" ? JSON.parse(local) : [];
  const lineItem = cartItems.find(
    (item) => item.product_id === product.product_id
  );

  if (!lineItem) {
    console.error("Item not found in cart");
    return;
  }

  try {
    const response = await axios.delete(
      API_URLS.REMOVE_CART_ITEM(lineItem.id),
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
  fetchCart();
};

const setItemQuantity = async (productId, quantity) => {
  const guestId = getGuestId();
  // Find the line item in the cart to get its ID
  const local = localStorage.getItem("cartItems");
  const cartItems = local && typeof local === "string" ? JSON.parse(local) : [];
  const lineItem = cartItems.filter(
    (item) => item.product_id === parseInt(productId)
  );

  if (!lineItem[0]) {
    console.error("Item not found in cart");
    return;
  }

  try {
    const response = await axios.put(
      API_URLS.UPDATE_CART_ITEM(lineItem[0].order_id),
      {
        guest_id: guestId,
        order: {
          line_items_attributes: [
            {
              id: lineItem[0].id,
              product_id: productId,
              quantity,
              price: lineItem[0].price,
            },
          ],
        },
      }
    );
    localStorage.setItem(
      "cartItems",
      JSON.stringify(response.data.updatedCartItems)
    );
  } catch (error) {
    console.error("Error updating item quantity:", error);
  }
};

export { fetchCart, addToCart, removeFromCart, setItemQuantity, getGuestId };
