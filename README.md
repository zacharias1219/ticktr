# **Ticketer - Ticket Marketplace SaaS**

**Ticketer** is a full-stack SaaS platform designed to revolutionize the ticket marketplace experience. Built with cutting-edge technology, it allows users to create, sell, and purchase event tickets in real-time with robust architecture and secure payment processing.

---

## **Features**

- **Event Creation and Management**:
  - Organize events with customizable details.
  - Add images, descriptions, and ticket pricing.

- **Ticket Sales and Purchases**:
  - Real-time ticket purchasing with a **queue system** to manage high demand.
  - Stripe Connect integration for secure payments and payouts.

- **Dynamic Updates**:
  - Real-time updates powered by **Convex backend**.
  - Automatically adjust availability and status of tickets.

- **User Authentication**:
  - Powered by **Clerk**, offering secure login and sign-up.
  - Multi-factor authentication (MFA) for enhanced security.

- **Refund System**:
  - Automates refunds upon event cancellation.
  - Ensures smooth processing for both buyers and event organizers.

- **Mobile-Responsive Design**:
  - Seamless experience across devices with **TailwindCSS** and responsive components.

---

## **Tech Stack**

- **Frontend**: Next.js 15, Shadcn (UI Components), TailwindCSS
- **Backend**: Convex for database and API management
- **Authentication**: Clerk for secure user authentication and MFA
- **Payments**: Stripe Connect for seamless payment and refund processing
- **Utility**: Cron jobs for scheduled tasks, Webhooks for real-time updates

---

## **Directory Structure**

```bash
├── app
│   ├── components
│   ├── pages
│   ├── services
│   ├── styles
│   ├── utils
├── convex
│   ├── schema
│   ├── functions
├── constants
├── public
│   └── assets
├── README.md
└── package.json
```

---

## **Setup and Installation**

### **Prerequisites**

1. **Node.js**: Version 16 or above.
2. **Convex Account**: Sign up at [Convex](https://convex.dev).
3. **Clerk Account**: Get API keys at [Clerk](https://clerk.dev).
4. **Stripe Account**: Set up Stripe Connect at [Stripe](https://stripe.com).

### **Steps**

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/yourusername/ticketer.git
   cd ticketer
   ```

2. **Install Dependencies**:

   ```bash
   npm install
   ```

3. **Set Environment Variables**:
   - Create a `.env.local` file in the root directory with the following:

     ```env
     NEXT_PUBLIC_CLERK_API_KEY=your_clerk_api_key
     NEXT_PUBLIC_CONVEX_URL=your_convex_url
     STRIPE_API_KEY=your_stripe_api_key
     ```

4. **Set Up Convex**:

   ```bash
   npx convex init
   ```

5. **Run the Application**:

   ```bash
   npm run dev
   ```

   Access the app at `http://localhost:3000`.

---

## **How It Works**

1. **Event Management**:
   - Users can create and edit events.
   - View events in a searchable and filterable interface.

2. **Ticket Purchase**:
   - Securely buy tickets with real-time availability updates.
   - Use Stripe Connect for payments and refunds.

3. **Queue System**:
   - Prevent overselling by managing concurrent purchases with Convex.

4. **Refund Automation**:
   - Process refunds automatically in case of event cancellations.

---

## **Future Enhancements**

- Add team collaboration features for event organizers.
- Implement advanced analytics for ticket sales insights.
- Include AI-based recommendations for popular events.

---

## **Contributing**

We welcome contributions! Please fork the repository, create a feature branch, and submit a pull request.

---

## **License**

This project is licensed under the MIT License. See the `LICENSE` file for more details.

---
