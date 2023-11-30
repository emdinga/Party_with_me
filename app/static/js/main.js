document.addEventListener('DOMContentLoaded', function() {
  console.log('Hello from main.js!');

  // Function to handle event creation form submission
  function handleEventCreationForm() {
    const eventForm = document.getElementById('event-creation-form');

    if (eventForm) {
      eventForm.addEventListener('submit', function(event) {
        event.preventDefault();

        // Extract form data and simulate an API request (replace with actual API call)
        const formData = new FormData(eventForm);
        simulateApiRequest(formData);
      });
    }
  }

  // Function to simulate an API request (replace with actual API call)
  function simulateApiRequest(formData) {
    // Simulate an API request (replace with actual API call)
    console.log('Simulating API request with data:', formData);

    // For demonstration purposes, show a success message and update the DOM
    const successMessage = document.createElement('p');
    successMessage.textContent = 'Event created successfully!';
    successMessage.style.color = 'green';

    const container = document.querySelector('.container');
    container.appendChild(successMessage);
  }

  // Call your functions
  handleEventCreationForm();
});
