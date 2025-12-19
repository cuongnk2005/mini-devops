// Sample products data
const products = [
  { id: 1, name: 'iPhone 15 Pro', desc: 'Điện thoại thông minh hàng đầu', price: '28.990.000đ', icon: '📱' },
  { id: 2, name: 'Samsung Galaxy S24', desc: 'Màn hình AMOLED siêu sắc nét', price: '22.990.000đ', icon: '📱' },
  { id: 3, name: 'iPad Pro 12.9"', desc: 'Máy tính bảng chuyên nghiệp', price: '18.990.000đ', icon: '📱' },
  { id: 4, name: 'MacBook Air M3', desc: 'Laptop hiệu năng cao', price: '34.990.000đ', icon: '💻' },
  { id: 5, name: 'AirPods Pro', desc: 'Tai nghe không dây chất lượng cao', price: '6.990.000đ', icon: '🎧' },
  { id: 6, name: 'Apple Watch Series 9', desc: 'Đồng hồ thông minh thế hệ mới', price: '12.990.000đ', icon: '⌚' },
  { id: 7, name: 'Sony WH-1000XM5', desc: 'Tai nghe chặn tiếng ồn tốt nhất', price: '8.990.000đ', icon: '🎧' },
  { id: 8, name: 'DJI Mini 4 Pro', desc: 'Flycam chuyên nghiệp mini', price: '15.990.000đ', icon: '🚁' },
];

const blogPosts = [
  { id: 1, title: 'iPhone 15 Pro - Đánh giá chi tiết', date: '15/12/2025', excerpt: 'Cùng khám phá những tính năng mới nhất của iPhone 15 Pro...', icon: '📱' },
  { id: 2, title: 'Cách chọn laptop phù hợp với công việc', date: '14/12/2025', excerpt: 'Hướng dẫn chi tiết cách lựa chọn laptop cho các lĩnh vực khác nhau...', icon: '💻' },
  { id: 3, title: 'Xu hướng công nghệ 2025', date: '13/12/2025', excerpt: 'Những công nghệ sẽ thay đổi thế giới trong năm tới...', icon: '🚀' },
  { id: 4, title: 'Mẹo bảo vệ thiết bị điện tử', date: '12/12/2025', excerpt: 'Cách chăm sóc và bảo vệ các thiết bị công nghệ của bạn...', icon: '🛡️' },
];

let cart = [];
let currentUser = null;

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
  loadCartFromStorage();
  updateCartCount();
  checkCurrentUser();
});

// Render products
function renderProducts(containerId = 'products-grid') {
  const container = document.getElementById(containerId);
  if (!container) return;
  
  container.innerHTML = products.map(product => `
    <div class="product-card">
      <div class="product-image">${product.icon}</div>
      <div class="product-info">
        <div class="product-name">${product.name}</div>
        <div class="product-desc">${product.desc}</div>
        <div class="product-footer">
          <span class="price">${product.price}</span>
          <button class="add-btn" onclick="addToCart(${product.id})">Thêm +</button>
        </div>
      </div>
    </div>
  `).join('');
}

// Render blog posts
function renderBlogPosts(containerId = 'blog-grid') {
  const container = document.getElementById(containerId);
  if (!container) return;

  container.innerHTML = blogPosts.map(post => `
    <div class="blog-card">
      <div class="blog-image">${post.icon}</div>
      <div class="blog-content">
        <div class="blog-date">${post.date}</div>
        <div class="blog-title">${post.title}</div>
        <div class="blog-desc">${post.excerpt}</div>
        <a href="#" class="read-more">Đọc thêm →</a>
      </div>
    </div>
  `).join('');
}

// Add to cart
function addToCart(productId) {
  const product = products.find(p => p.id === productId);
  if (product) {
    cart.push(product);
    saveCartToStorage();
    updateCartCount();
    showToast(`${product.name} đã được thêm vào giỏ hàng!`);
  }
}

// Remove from cart
function removeFromCart(index) {
  if (cart[index]) {
    const product = cart[index];
    cart.splice(index, 1);
    saveCartToStorage();
    updateCartCount();
    showToast(`${product.name} đã được xóa khỏi giỏ hàng`);
    renderCartItems();
  }
}

// Update cart count
function updateCartCount() {
  const countEl = document.getElementById('cart-count');
  if (countEl) {
    countEl.textContent = cart.length;
  }
}

// Render cart items
function renderCartItems() {
  const container = document.getElementById('cart-items');
  if (!container) return;

  if (cart.length === 0) {
    container.innerHTML = '<div style="text-align: center; padding: 40px; color: #666;">Giỏ hàng của bạn đang trống</div>';
    return;
  }

  container.innerHTML = cart.map((item, index) => `
    <div class="cart-item">
      <div class="item-info">
        <div class="item-name">${item.name}</div>
        <div class="item-price">${item.price}</div>
      </div>
      <button class="remove-btn" onclick="removeFromCart(${index})">Xóa</button>
    </div>
  `).join('');

  updateCartTotal();
}

// Update cart total
function updateCartTotal() {
  const totalEl = document.getElementById('cart-total');
  if (!totalEl) return;

  // Simple calculation - remove "đ" and "." for math
  const total = cart.reduce((sum, item) => {
    const price = parseInt(item.price.replace(/\./g, '').replace('đ', ''));
    return sum + price;
  }, 0);

  totalEl.textContent = new Intl.NumberFormat('vi-VN').format(total) + 'đ';
}

// Save/Load cart from localStorage
function saveCartToStorage() {
  localStorage.setItem('techstore-cart', JSON.stringify(cart));
}

function loadCartFromStorage() {
  const saved = localStorage.getItem('techstore-cart');
  if (saved) {
    cart = JSON.parse(saved);
  }
}

// Toggle cart visibility
function toggleCart() {
  if (cart.length === 0) {
    showToast('Giỏ hàng của bạn đang trống!');
    return;
  }
  window.location.href = 'cart.html';
}

// Scroll to products
function scrollToProducts() {
  const el = document.getElementById('products');
  if (el) {
    el.scrollIntoView({ behavior: 'smooth' });
  }
}

// Show toast notification
function showToast(message) {
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.textContent = message;
  document.body.appendChild(toast);

  setTimeout(() => {
    toast.remove();
  }, 2000);
}

// User Account Functions
function saveUser(userData) {
  localStorage.setItem('techstore-user', JSON.stringify(userData));
  currentUser = userData;
  updateUserUI();
}

function getCurrentUser() {
  const saved = localStorage.getItem('techstore-user');
  if (saved) {
    currentUser = JSON.parse(saved);
  }
  return currentUser;
}

function checkCurrentUser() {
  const user = getCurrentUser();
  updateUserUI();
}

function updateUserUI() {
  const loginBtn = document.getElementById('login-btn');
  const accountBtn = document.getElementById('account-btn');

  if (currentUser) {
    if (loginBtn) loginBtn.style.display = 'none';
    if (accountBtn) {
      accountBtn.style.display = 'block';
      accountBtn.textContent = `👤 ${currentUser.name.split(' ')[0]}`;
    }
  } else {
    if (loginBtn) loginBtn.style.display = 'block';
    if (accountBtn) accountBtn.style.display = 'none';
  }
}

function logout() {
  localStorage.removeItem('techstore-user');
  currentUser = null;
  updateUserUI();
  showToast('Đã đăng xuất');
  window.location.href = 'index.html';
}

// Handle contact form submission
function handleContactForm(e) {
  e.preventDefault();
  
  const formData = {
    name: document.getElementById('name').value,
    email: document.getElementById('email').value,
    subject: document.getElementById('subject').value,
    message: document.getElementById('message').value
  };

  console.log('Form submitted:', formData);
  showToast('Cảm ơn bạn! Chúng tôi sẽ liên hệ lại sớm.');
  e.target.reset();
}

// Handle account login form
function handleLoginForm(e) {
  e.preventDefault();

  const formData = {
    name: document.getElementById('full-name').value,
    email: document.getElementById('email').value,
    phone: document.getElementById('phone').value,
    address: document.getElementById('address').value
  };

  saveUser(formData);
  showToast('Đăng nhập thành công!');
  window.location.href = 'account.html';
}

// Format currency
function formatCurrency(amount) {
  return new Intl.NumberFormat('vi-VN').format(amount) + 'đ';
}

// Search products
function searchProducts(query) {
  const filtered = products.filter(p => 
    p.name.toLowerCase().includes(query.toLowerCase()) ||
    p.desc.toLowerCase().includes(query.toLowerCase())
  );
  
  const container = document.getElementById('products-grid');
  if (!container) return;

  if (filtered.length === 0) {
    container.innerHTML = '<div style="grid-column: 1/-1; text-align: center; color: white; padding: 40px;">Không tìm thấy sản phẩm phù hợp</div>';
    return;
  }

  container.innerHTML = filtered.map(product => `
    <div class="product-card">
      <div class="product-image">${product.icon}</div>
      <div class="product-info">
        <div class="product-name">${product.name}</div>
        <div class="product-desc">${product.desc}</div>
        <div class="product-footer">
          <span class="price">${product.price}</span>
          <button class="add-btn" onclick="addToCart(${product.id})">Thêm +</button>
        </div>
      </div>
    </div>
  `).join('');
}
