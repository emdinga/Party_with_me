// static/js/scripts.js
document.addEventListener('DOMContentLoaded', function() {
    // Function to open a modal
    function openModal(modalId) {
        document.getElementById(modalId).style.display = 'block';
    }

    // Function to close a modal
    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    // Open Terms of Service modal
    document.querySelector('[data-open="terms"]').addEventListener('click', function() {
        openModal('terms-modal');
    });

    // Open Privacy Policy modal
    document.querySelector('[data-open="privacy"]').addEventListener('click', function() {
        openModal('privacy-modal');
    });

    // Close modals when clicking on the close button
    document.querySelectorAll('.close-button').forEach(function(button) {
        button.addEventListener('click', function() {
            closeModal(button.getAttribute('data-close'));
        });
    });

    // Close modals when clicking outside of the modal content
    window.addEventListener('click', function(event) {
        if (event.target.classList.contains('modal')) {
            closeModal(event.target.id);
        }
    });
});

