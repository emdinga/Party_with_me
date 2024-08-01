document.addEventListener('DOMContentLoaded', () => {
    // Open modals
    document.querySelectorAll('.footer-link').forEach(link => {
        link.addEventListener('click', (event) => {
            const modalId = event.target.getAttribute('data-modal') + '-modal';
            document.getElementById(modalId).style.display = 'flex';
        });
    });

    // Close modals
    document.querySelectorAll('.close-button').forEach(button => {
        button.addEventListener('click', () => {
            const modal = button.closest('.modal');
            modal.style.display = 'none';
        });
    });

    // Close modals when clicking outside of the modal
    window.addEventListener('click', (event) => {
        if (event.target.classList.contains('modal')) {
            event.target.style.display = 'none';
        }
    });
});
