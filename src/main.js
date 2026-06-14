import './style.css';

document.addEventListener('DOMContentLoaded', () => {
  // --- SPA ROUTER ---
  const sections = document.querySelectorAll('.page-section');
  const navLinks = document.querySelectorAll('.nav-link');
  const progressBar = document.getElementById('progress-bar');

  function handleRoute() {
    const hash = window.location.hash || '#home';
    let targetSection = document.querySelector(hash);

    if (!targetSection) {
      targetSection = document.getElementById('home');
    }

    // Update active navigation links
    navLinks.forEach((link) => {
      if (link.getAttribute('href') === hash) {
        link.classList.add('active');
      } else {
        link.classList.remove('active');
      }
    });

    // Animate progress bar transition
    progressBar.style.width = '30%';
    setTimeout(() => {
      progressBar.style.width = '70%';
    }, 100);

    // Toggle active classes on sections
    sections.forEach((section) => {
      section.classList.remove('active', 'visible');
    });

    setTimeout(() => {
      targetSection.classList.add('active');
      window.scrollTo(0, 0);
      
      // Trigger animations
      setTimeout(() => {
        targetSection.classList.add('visible');
        progressBar.style.width = '100%';
        setTimeout(() => {
          progressBar.style.width = '0%';
        }, 300);
      }, 50);
    }, 200);

    // Close mobile menu if open
    const navMenu = document.getElementById('nav-menu');
    const menuToggle = document.getElementById('menu-toggle');
    if (navMenu.classList.contains('active')) {
      navMenu.classList.remove('active');
      menuToggle.classList.remove('active');
    }
  }

  window.addEventListener('hashchange', handleRoute);
  // Initialize route on load
  handleRoute();

  // --- MOBILE HAMBURGER MENU ---
  const menuToggle = document.getElementById('menu-toggle');
  const navMenu = document.getElementById('nav-menu');

  if (menuToggle && navMenu) {
    menuToggle.addEventListener('click', () => {
      menuToggle.classList.toggle('active');
      navMenu.classList.toggle('active');
    });
  }

  // --- HEADER SCROLL EFFECT ---
  const header = document.getElementById('main-header');
  window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }
  });

  // --- GALLERY FILTER ---
  const filterBtns = document.querySelectorAll('.filter-btn');
  const galleryItems = document.querySelectorAll('.gallery-item');

  filterBtns.forEach((btn) => {
    btn.addEventListener('click', (e) => {
      // Remove active class from buttons
      filterBtns.forEach((b) => b.classList.remove('active'));
      btn.classList.add('active');

      const filterValue = btn.getAttribute('data-filter');

      galleryItems.forEach((item) => {
        if (filterValue === 'all' || item.getAttribute('data-category') === filterValue) {
          item.style.display = 'block';
          setTimeout(() => {
            item.style.opacity = '1';
            item.style.transform = 'scale(1)';
          }, 50);
        } else {
          item.style.opacity = '0';
          item.style.transform = 'scale(0.95)';
          setTimeout(() => {
            item.style.display = 'none';
          }, 300);
        }
      });
    });
  });

  // --- LIGHTBOX MODAL ---
  const lightbox = document.getElementById('lightbox');
  const lightboxImg = document.getElementById('lightbox-img');
  const lightboxCaption = document.getElementById('lightbox-caption');
  const closeBtn = document.getElementById('lightbox-close-btn');

  galleryItems.forEach((item) => {
    const zoomBtn = item.querySelector('.zoom-btn');
    const img = item.querySelector('img');
    const title = item.querySelector('.item-title');

    if (zoomBtn && img && lightbox && lightboxImg) {
      zoomBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        lightboxImg.src = img.src;
        if (lightboxCaption && title) {
          lightboxCaption.textContent = title.textContent;
        }
        lightbox.classList.add('active');
      });
    }
  });

  if (closeBtn && lightbox) {
    closeBtn.addEventListener('click', () => {
      lightbox.classList.remove('active');
    });

    lightbox.addEventListener('click', (e) => {
      if (e.target === lightbox) {
        lightbox.classList.remove('active');
      }
    });
  }

  // Escape key to close lightbox
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && lightbox.classList.contains('active')) {
      lightbox.classList.remove('active');
    }
  });

  // --- BOOKING FORM VALIDATION & SUBMISSION ---
  const bookingForm = document.getElementById('booking-form');
  const bookingSuccess = document.getElementById('booking-success');
  const successBackBtn = document.getElementById('success-back-btn');

  if (bookingForm && bookingSuccess) {
    bookingForm.addEventListener('submit', (e) => {
      e.preventDefault();

      const inputs = bookingForm.querySelectorAll('input, select, textarea');
      let isValid = true;

      // Validate inputs
      inputs.forEach((input) => {
        const formGroup = input.closest('.form-group');
        if (!formGroup) return;

        if (input.hasAttribute('required')) {
          if (!input.value.trim()) {
            formGroup.classList.add('invalid');
            isValid = false;
          } else {
            formGroup.classList.remove('invalid');
          }
        }

        // Email validation regex
        if (input.type === 'email' && input.value.trim()) {
          const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
          if (!emailRegex.test(input.value.trim())) {
            formGroup.classList.add('invalid');
            isValid = false;
          } else {
            formGroup.classList.remove('invalid');
          }
        }
      });

      if (isValid) {
        const submitBtn = document.getElementById('booking-submit-btn');
        const btnText = submitBtn.querySelector('.btn-text');
        const spinner = submitBtn.querySelector('.spinner');

        // Show spinner state
        submitBtn.disabled = true;
        btnText.style.opacity = '0.5';
        spinner.classList.remove('hidden');

        // Mock network delay (1.5 seconds)
        setTimeout(() => {
          bookingForm.classList.add('hidden');
          bookingSuccess.classList.remove('hidden');
          
          // Reset loading state
          submitBtn.disabled = false;
          btnText.style.opacity = '1';
          spinner.classList.add('hidden');
          
          // Reset form fields
          bookingForm.reset();
        }, 1500);
      }
    });

    if (successBackBtn) {
      successBackBtn.addEventListener('click', () => {
        bookingSuccess.classList.add('hidden');
        bookingForm.classList.remove('hidden');
      });
    }
  }
});
