#PARTY WITH ME

Party with me is an application that allows people to host parties and invite online friends or people around the area to join the party.


2. Team Members

Emdinga Mbhamali- Full stack developer who will complete the project alone

3. Technologies
Programming Language:

Chosen Technology: Python
Alternative: JavaScript
Trade-offs: Python is known for its simplicity, readability, and a wide range of libraries for web development. JavaScript is commonly used for web applications, especially for frontend development. The choice of Python is due to  familiarity with the language and the desire for a straightforward backend. JavaScript will be an alternative for frontend development.

Backend Framework:
	Chosen Technology: Flask
Alternative: Django
Trade-offs: Django is a high-level web framework with many built-in features, including authentication and admin panels. Flask is a microframework, offering more flexibility and control but requiring manual setup of components.

Database:
	Chosen Technology: MySQL
	Alternative : PostgreSQL
Trade-offs: MySQL is more straightforward and often chosen for smaller         applications. PostgreSQL is known for its advanced features, data integrity, and support for complex queries

Real Time communication:
	Chosen Technology: WebSocket
	Alternative: Server-Sent Events (SSE)
Trade-offs: Websockets enable two-way communication, making them suitable for real time features. SSE is simpler but one way.
 
Mapping and Location services:
	Chosen Technology: Google Maps API
	Alternative: MapBox
	Trade-offs: Google maps is widely recognized and offers extensive features.

4. Challenge statement
The Party with Me Project aims to address the following problem:
Organising and Inviting Guests to House Parties: Many individuals face challenges when organising and hosting house parties, such as coordinating guest invitations, managing RSVPs, and providing event details. This project intends to simplify the process of planning and hosting house parties by providing a digital platform for users to create and manage party events, invite guests, and share essential information.

What the "Party with Me Project" Will Not Solve:
Physical Event Execution: The project will assist in the organisation and planning of house parties but will not physically execute or manage the event. Users will still be responsible for the actual hosting of the party.

Guest Behaviour: While the project facilitates guest invitations and RSVP management, it does not control or influence guest behaviour, preferences, or interactions during the party.

5. Risks
Technical risks:
Data Security and Privacy: Storing user data and event details in the application poses a potential risk of data breaches and privacy violations. Safeguards include implementing robust security measures, such as encryption, access controls, and regular security audits. Compliance with data protection regulations e.g GDPR is essential.

Scalability: If the platform gains popu;arity, scaling issues could lead to performance problems and system downtime. To mitigate this, the application can be built on scalable cloud infrastructure like AWS, Azure and regularly optimised for performance.

Integration with Third-Party Services: Integrating with external services e.g social media platforms carries the risk of changes in APIs or service disruptions. Regular monitoring of integration points and the availability of backup options will serve as safeguards.

Software Bugs and Glitches: Software development inherently carries the risk of bugs and glitches. Rigorous testing, including unit tests and user acceptance testing, will help identify and address issues before deployment.

Non-Technical Risks and Strategies:
User Behaviour: Inappropriate guest behaviour or disputes among users may impact the party atmosphere and user experience. Implementing community guidelines, moderation, and reporting mechanisms can help manage these risks.

Negative User Reviews: Negative reviews or experiences shared by users can harm the platform's reputation. Offering responsive customer support, addressing user concerns, and actively seeking user feedback can help mitigate this risk.

Marketing and User Adoption: Attracting users to the platform and ensuring active participation in events are non-technical challenges. Effective marketing, community building, and user engagement strategies can help address these concerns.

Competition and Market Changes: The party planning and social gathering space may have competition and evolving market trends. Staying updated, offering unique features, and maintaining flexibility can mitigate the impact of market changes.

6. Infrastructure
Branching and Merging: We will utilise code review tools e.g GitHub's pull request feature to ensure quality code and collaboration. Merging into "master" requires at least one approving review.

Deployment: For deployment, we utilise cloud services like AWS, Azure, or Google Cloud Platform. We maintain separate environments for development, staging, and production. Automated deployment scripts and configuration management tools e.g Ansible are used to ensure consistent deployments.

Data Population:To populate the app with data, we implement data seeding scripts. These scripts can import initial data or generate sample data for testing and development purposes. Data seeding ensures that the application starts with essential information, such as default user accounts, sample events, or configuration settings.

Testing: Our testing strategy incorporates both manual and automated testing. We use the following tools and processes
Unit Testing: We will write unit tests using frameworks like Pytest (for Python). These tests validate individual components of the code. 


7. Existing Solutions
	Evite
	FAcebook Events
	Meetup
	Eventbrite

	Similarities:
	All these solutions focus on event management and invitation.
	They Allow users to create events and invite guests.
RSVP tracking is a common feature and Users can communicate and share event details.

Choice for Reimplement:

Our Project is designed to address a specific niche within the event management domain. It focuses on informal gatherings and house parties, which are different from the typical events managed by the above solutions.


In summary our project is designed to serve users looking for a dedicated platform for organising and participating in house parties. It offers a distinct user experience compared to broader event management solutions. PARTY WITH ME.

