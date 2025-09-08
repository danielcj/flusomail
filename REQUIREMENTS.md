# Flusomail - Open Source Email Marketing System

## Core Requirements

### Unsubscribe Management
- **Global unsubscribe lists**: System-wide opt-out management across all campaigns
- **Individual unsubscription groups**: Granular control allowing users to opt-out of specific types of communications while remaining subscribed to others

### Analytics & Reporting  
- **Clear statistics on bounces and deliveries**: Comprehensive tracking and reporting of email delivery metrics
- Real-time dashboard showing campaign performance
- Detailed logs for troubleshooting delivery issues

### Template Management
- **Easy to build and edit templates with AI prompts**: AI-assisted template creation and optimization
- Drag-and-drop visual editor
- Template versioning and A/B testing capabilities

### Audience Segmentation
- **Very good segmentation based on as many attributes as needed**: Flexible, multi-dimensional audience targeting
- Custom fields and properties
- Dynamic segmentation based on behavior and engagement
- Boolean logic for complex segment rules

### Automation
- **Easy to build simple automations**: User-friendly automation builder
- Trigger-based workflows (welcome series, abandoned cart, etc.)
- Time-based sequences
- Conditional logic support

### Email Infrastructure
- **Integration with SES or other SMTP servers**: Support for major email service providers
- API integrations for SendGrid, Mailgun, Postmark, etc.
- Delivery optimization and failover capabilities

### Domain & Sender Management
- **Simple to validate domains/senders on DNS records**: Automated DNS validation tools
- SPF, DKIM, and DMARC record verification
- Sender reputation monitoring
- **Note**: System relies on external providers (SES, SendGrid) for actual sending - we don't handle direct SMTP sending

## Wishlist Features

### Multi-Channel Communications
- **Advanced workflows that mix email, SMS, push notifications**: Unified communication platform
- Cross-channel journey orchestration
- Channel preference management per subscriber

### Testing & Optimization
- **A/B tests**: Built-in split testing for subject lines, content, send times
- Statistical significance tracking
- Automated winner selection

### AI-Powered Personalization
- **VERY custom AI emails to increase engagement**: Advanced AI-driven content personalization
- Dynamic content generation based on subscriber behavior
- Predictive send time optimization
- Sentiment analysis and response optimization

## Technical Considerations

### Architecture Goals
- Open source and self-hostable
- Cloud-native design with container support
- Horizontal scaling capabilities
- API-first architecture

### Integration Requirements
- RESTful API for third-party integrations
- Webhook support for real-time data sync
- Import/export capabilities for major platforms
- GDPR and privacy compliance features