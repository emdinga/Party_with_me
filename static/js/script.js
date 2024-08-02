document.addEventListener('DOMContentLoaded', function () {
    const seeMoreLink = document.querySelector('.see-more-link');
    const seeMoreSection = document.querySelector('.see-more');
    const termsModal = document.getElementById('termsModal');
    const privacyModal = document.getElementById('privacyModal');

    seeMoreLink.addEventListener('click', function (event) {
        event.preventDefault();
        if (seeMoreSection.style.display === 'block') {
            seeMoreSection.style.display = 'none';
            seeMoreLink.textContent = 'See More';
        } else {
            seeMoreSection.style.display = 'block';
            seeMoreLink.textContent = 'See Less';
            seeMoreSection.scrollIntoView({ behavior: 'smooth' });
        }
    });

    document.querySelectorAll('.close-button').forEach(button => {
        button.addEventListener('click', function () {
            button.closest('.modal').style.display = 'none';
        });
    });

    window.showModal = function (modalId) {
        document.getElementById(modalId).style.display = 'flex';
    };

    window.hideModal = function (modalId) {
        document.getElementById(modalId).style.display = 'none';
    };
});
