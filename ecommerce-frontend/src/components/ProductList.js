import React, { useState, useEffect } from "react";
import axios from "axios";
import ProductCard from "./ProductCard";
import API_URLS from "../utils/apiUrls";

function ProductList() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    axios
      .get(API_URLS.LIST_PRODUCTS)
      .then((response) => {
        setProducts(response.data);
      })
      .catch((error) => {
        console.error("There was an error fetching the products:", error);
      });
  }, []);

  return (
    <div className="p-4">
      <h2 className="text-2xl font-bold mb-4">Products</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {products.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>
    </div>
  );
}

export default ProductList;
