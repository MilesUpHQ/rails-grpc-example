// src/components/Footer.js

import React from "react";

function Footer() {
  return (
    <footer className="bg-white-800 text-grey text-center p-4 mt-8">
      <p>
        &copy; {new Date().getFullYear()} E-commerce App. All rights reserved.
      </p>
    </footer>
  );
}

export default Footer;
