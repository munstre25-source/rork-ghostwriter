# GhostWriter: Optimized 3-Part Development Prompts

## Part 1: GhostWriter — Core Architecture, Live Presence, On-Device AI, and Creator Infrastructure

**Objective**: Build the core architecture for **GhostWriter**, a native iOS "creative partner" app that transforms solitary thinking into a live, collaborative, and monetizable experience using Dynamic Island, CoreML, on-device LLMs, and creator-first infrastructure.

---

### 1. Core Architectural Principles

- **100% iOS Native**: Build with Swift and SwiftUI only. Prioritize performance and native feel.
- **Live-First Presence**: The app must feel "alive" and present even when in the background via Dynamic Island and Live Activities.
- **Privacy-First AI**: All text analysis, ghost suggestions, and personality training happen on-device using CoreML and quantized LLMs. Zero cloud processing of creative content.
- **Low-Latency Interaction**: Haptic feedback and Dynamic Island updates must be instantaneous (<100ms) to maintain "flow state."
- **Creator-Centric Design**: Architecture must support creator monetization, analytics, and community features from day one.
- **Ephemeral + Persistent**: Sessions are ephemeral (focus on process), but clips, stats, and achievements are persistent (encourage return).

---

### 2. Data Schema & Persistence (SwiftData)

Use SwiftData to manage live sessions, ghost personalities, creator profiles, and monetization data.

#### **`CreativeSession` Entity**
```
- id: UUID
- userId: UUID
- startTime: Date
- endTime: Date?
- title: String?
- type: String (writing, brainstorming, coding, design, freestyle)
- rawInputLog: [String] (incremental snippets of thoughts)
- isLive: Bool
- isPublic: Bool (discoverable by others)
- personalityId: UUID (which ghost is active)
- collaboratorIds: [UUID] (for Live Jam sessions)
- wordCount: Int
- ideaCount: Int (number of accepted ghost suggestions)
- flowScore: Double (0-100, based on typing cadence and consistency)
- moodDetected: String? (frustrated, focused, creative, etc.)
- createdClipIds: [UUID] (GhostClips created from this session)
- bookmarkedBy: [UUID] (users who bookmarked this session)
- isMonetized: Bool (eligible for CPM revenue)
```

#### **`GhostPersonality` Entity**
```
- id: UUID
- name: String (e.g., "The Muse," "The Architect," "The Critic")
- description: String
- systemPrompt: String (on-device LLM instruction)
- creatorId: UUID? (nil if built-in, UUID if user-created)
- hapticPattern: String (identifier for unique vibration style)
- voiceId: String (for text-to-speech)
- traits: [String] (encouraging, critical, analytical, playful, etc.)
- responseStyle: String (short/long, formal/casual, etc.)
- usageCount: Int (for analytics)
- rating: Double (user ratings, 0-5)
- purchasePrice: Double? (nil if free, price if premium)
- revenue: Double (total revenue generated)
- downloads: Int
- isPublished: Bool (available in marketplace)
- customTrainingData: [String]? (user's past sessions, for personalization)
```

#### **`GhostSuggestion` Entity**
```
- id: UUID
- sessionId: UUID
- personalityId: UUID
- content: String
- type: String (continuation, challenge, summary, reframe, expand)
- confidenceScore: Double (0-1, how confident the AI is)
- accepted: Bool?
- userRating: Int? (-1 for dislike, 0 for neutral, 1 for like)
- timestamp: Date
- contextBefore: String (text before suggestion)
- contextAfter: String (text after suggestion)
```

#### **`GhostClip` Entity**
```
- id: UUID
- sessionId: UUID
- creatorId: UUID
- videoURL: URL
- duration: Double
- thumbnailURL: URL?
- title: String?
- description: String?
- createdAt: Date
- shareCount: Int
- viewCount: Int
- likeCount: Int
- saveCount: Int
- isMonetized: Bool
- cpmRevenue: Double
- isPublic: Bool
- personalityUsed: String
```

#### **`CreatorProfile` Entity**
```
- id: UUID
- userId: UUID
- username: String (unique)
- bio: String?
- profileImageURL: URL?
- followerCount: Int
- followingCount: Int
- totalClipViews: Int
- totalClipLikes: Int
- totalEarnings: Double
- totalSessionsCreated: Int
- favoritePersonalities: [UUID]
- badges: [String] (achievements)
- isVerified: Bool
- socialLinks: [String: String] (Twitter, Instagram, etc.)
- createdPersonalities: [UUID]
- publicSessions: [UUID]
```

#### **`CreativeStreak` Entity**
```
- id: UUID
- userId: UUID
- currentStreak: Int (consecutive days)
- longestStreak: Int
- lastSessionDate: Date
- streakStartDate: Date
- totalSessionsInStreak: Int
- totalWordsInStreak: Int
```

#### **`WeeklyChallenge` Entity**
```
- id: UUID
- title: String
- description: String
- personalityRequired: UUID?
- targetWordCount: Int?
- targetSessionCount: Int?
- startDate: Date
- endDate: Date
- participantCount: Int
- leaderboard: [(userId: UUID, score: Int, rank: Int)]
- sponsorId: UUID? (for sponsored challenges)
- sponsorAmount: Double?
```

#### **`UserAnalytics` Entity**
```
- id: UUID
- userId: UUID
- date: Date
- sessionCount: Int
- totalSessionMinutes: Int
- totalWordsWritten: Int
- ideasGenerated: Int
- mostProductiveHour: Int? (0-23)
- mostProductiveDay: String? (Monday-Sunday)
- favoritePersonality: UUID?
- moodDistribution: [String: Int] (mood -> count)
- flowStateMinutes: Int (time in flow state)
- collaborationCount: Int
```

---

### 3. Core Engines

#### **Live Ingest Engine**
- Monitor user input via:
  - Direct text input in app
  - Keyboard extension (optional, v1.1)
  - Share Extension (send text from any app)
  - Dictation-to-text with real-time processing
  - Clipboard monitoring (optional)
- Process input incrementally (word-by-word, not sentence-by-sentence)
- Detect typing cadence to infer mood and flow state
- Track pause duration to detect creative blocks

#### **Ghost Intelligence Engine (CoreML + On-Device LLM)**
- Run quantized LLMs on-device:
  - Llama 2 7B (quantized to 4-bit) for base model
  - DistilBERT for mood/intent detection
  - GPT-2 medium for lightweight suggestions
- Real-time text completion and brainstorming:
  - Suggest next sentence/paragraph
  - Challenge user's assumptions
  - Summarize current thoughts
  - Reframe ideas from different angles
  - Expand on ideas
- Personality-driven responses:
  - Apply personality system prompt before generating
  - Adjust response style (length, tone, formality)
  - Learn from user feedback (on-device)
- Confidence scoring:
  - Rate each suggestion 0-1 based on context fit
  - Visualize confidence to user
  - Only show high-confidence suggestions by default
- Mood detection:
  - Analyze typing speed, word choice, punctuation
  - Detect: focused, frustrated, creative, tired, excited
  - Suggest personality that matches mood

#### **Presence Engine (ActivityKit + Dynamic Island)**
- Manage Dynamic Island states:
  - **Idle**: "Ready to create"
  - **Thinking**: "Session active - X words written"
  - **Suggesting**: "Ghost has an idea..."
  - **Flowing**: "In flow state - keep going!"
- Live Activities:
  - Show real-time word count
  - Display current personality
  - Show streak status
  - Quick action buttons (pause, end, share)
- Background updates:
  - Update every 10 seconds during active session
  - Show notifications for milestones (100 words, 10 ideas, etc.)

#### **Sensory Engine (CoreHaptics)**
- Translate AI confidence levels into haptic feedback:
  - Low confidence: Single light tap
  - Medium confidence: Double tap
  - High confidence: Triple tap with pulse
- Personality-specific haptics:
  - The Muse: Gentle, flowing pulses
  - The Architect: Precise, rhythmic taps
  - The Critic: Sharp, staccato taps
- Flow state indicators:
  - Subtle heartbeat-like pulse when in flow
  - Celebratory haptic on milestones
- Collaboration haptics:
  - Different haptic for each collaborator in Live Jam
  - Haptic when collaborator types something

#### **Creator Analytics Engine**
- Track:
  - Session frequency and duration
  - Most productive times (hour, day of week)
  - Personality preferences
  - Clip performance (views, engagement)
  - Earnings (CPM, personality sales, tips)
  - Collaboration frequency
  - Follower growth
- Generate insights:
  - "You're most creative on Thursdays at 10am"
  - "The Architect is your most-used personality"
  - "Your clips average 500 views"
  - "You've earned $47 this month"
- Push insights to user via notifications

#### **Monetization Engine**
- Track:
  - Clip views and CPM revenue
  - Personality sales and revenue share
  - Referral bonuses
  - Tip revenue
  - Subscription tier
- Calculate:
  - Creator payout (70% of marketplace revenue)
  - Platform revenue (30%)
  - CPM rates based on clip performance
- Manage:
  - Payout schedule (monthly)
  - Tax documentation
  - Revenue splits for collaborations

---

### 4. Platform Integrations

#### **Dynamic Island & Live Activities**
- Show session progress in Dynamic Island
- Quick actions: pause, end, share
- Notification of Ghost suggestions
- Streak status updates

#### **Share Extension**
- Send text/ideas from any app (Notes, Mail, Safari, etc.) into a Ghost Session
- Automatically create a session with context
- Option to continue in GhostWriter or just save

#### **App Intents & Shortcuts**
- "Start a Ghost Session with The Muse"
- "Ask my Ghost for an idea"
- "Show me my creative stats"
- "Start a Live Jam with @friend"

#### **Keyboard Extension (v1.1)**
- Provide Ghost suggestions directly in any text field
- Works in Notes, Mail, Messages, etc.
- Optional, requires user permission

#### **Creative Tool Integrations (v1.2)**
- **Notion**: Save sessions directly to Notion database
- **GitHub**: Create code snippets from sessions
- **Figma**: Export design briefs from sessions
- **Google Docs**: Sync session notes to Docs
- **Obsidian**: Integrate with personal knowledge base

#### **Social Integrations**
- Share GhostClips to TikTok, Instagram Reels, YouTube Shorts
- Deep links to join sessions or try personalities
- Creator profile links in clips

---

### 5. Offline Support

- Sessions work completely offline (local-only)
- Ghost AI suggestions work offline (on-device CoreML)
- Sync to cloud when connection returns
- Queue actions (shares, publishes) to send when online
- Graceful degradation (no cloud features when offline)

---

### 6. Accessibility Features

#### **Voice-First Mode**
- Dictation-to-text with real-time ghost suggestions
- Voice feedback from Ghost AI (text-to-speech)
- Haptic feedback for voice sessions
- Export as audio/podcast
- Supports multiple languages

#### **Universal Design**
- VoiceOver support for blind users
- Dyslexia-friendly fonts (OpenDyslexic)
- High contrast mode
- Adjustable text size
- Haptic feedback as alternative to visual cues

---

## Part 2: GhostWriter — UI/UX Design, Live Jam Collaboration, Creator Marketplace, and Viral Growth

**Objective**: Deliver a high-energy, creator-centric UX for GhostWriter that makes creative thinking feel like a shared performance, with built-in monetization, community discovery, and viral growth loops.

---

### 1. User Interface Architecture (SwiftUI)

#### **Design Direction**
- **Aesthetic**: Minimalist + energetic. Glowing neon accents, organic shapes, smooth animations.
- **Color Palette**:
  - Background: Deep black (#0A0A0A)
  - Accents: Neon cyan (#00D9FF), magenta (#FF00FF), emerald (#00FF88), gold (#FFD700)
  - Text: Light gray (#E8E8E8)
- **Typography**:
  - Display: Space Grotesk (bold, futuristic)
  - Body: Inter (clean, readable)
- **Motion**: Framer Motion-style smooth transitions, micro-interactions on every tap

#### **Primary Navigation**
- **Tab 1: Live** (main creative canvas)
- **Tab 2: Discover** (community, trending, recommendations)
- **Tab 3: Clips** (user's GhostClips, leaderboard)
- **Tab 4: Creator** (profile, analytics, earnings)
- **Tab 5: Settings** (preferences, integrations, account)

#### **The "GhostBoard" (Main Canvas)**
- Fluid, non-linear canvas where text and AI suggestions float and react to touch
- Real-time word count and flow score
- Ghost personality avatar (animated, reacts to suggestions)
- Suggestion cards that appear and fade
- Haptic feedback on every interaction
- Session timer in Dynamic Island
- Quick actions: pause, end, share, bookmark

#### **Session Types UI**
- **Writing**: Focused text input with suggestions
- **Brainstorming**: Rapid-fire ideas, visual mind map
- **Coding**: Code-focused suggestions, syntax highlighting
- **Design**: Visual inspiration, design briefs
- **Freestyle**: Open-ended, no specific format

---

### 2. Collaborative "Live Jam" (SharePlay)

#### **SharePlay Integration**
- Use GroupActivities framework to sync GhostBoard over FaceTime
- Both users' inputs are synthesized by a single "Ghost" AI in real-time
- Shared cursor/caret shows where collaborator is typing
- Real-time suggestion voting (both users can accept/reject)

#### **Shared Intent**
- Ghost AI sees both users' input streams
- Generates suggestions that bridge both perspectives
- Personality adapts to both users' styles
- Collaboration score tracks how well they work together

#### **Spatial Audio**
- Use AVAudioSession to place Ghost's voice in 3D space
- Each collaborator's typing has subtle audio cue
- Haptic feedback synchronized across devices

#### **Collaboration Features**
- Shared session history
- Ability to "tag" collaborator's ideas
- Collaboration badges/achievements
- Option to make session public and share with community

#### **Post-Jam**
- Automatic GhostClip creation of best moments
- Shared clip (both creators get credit)
- Option to split earnings

---

### 3. Creator Marketplace & Discovery

#### **Personality Marketplace**
- Browse personalities created by other users
- Filter by: category, rating, price, trending
- Try personality for free (1 session)
- Purchase to use unlimited ($1.99-$9.99)
- Creator earns 70% of sale price
- Rating system (1-5 stars)
- Creator profile linked to personality

#### **Session Discovery Feed**
- Browse public sessions from creators
- Filter by: personality, type, trending, friends
- See session stats: word count, ideas, flow score
- Option to "fork" a session (start a similar one)
- One-tap to try the same personality

#### **Trending Personalities & Challenges**
- Weekly featured personalities
- Creative challenges with leaderboards
- Sponsored challenges (brands pay to sponsor)
- Exclusive rewards for challenge winners
- Community voting on next week's personality

#### **Creator Profiles**
- Public profile showing:
  - Bio and links (Twitter, Instagram, etc.)
  - Best clips
  - Favorite personalities
  - Follower count
  - Collaboration history
  - Total earnings
  - Badges/achievements
- Follow creators to see their clips
- Tip creators directly

#### **Leaderboards**
- Global leaderboard (most viewed clips, earnings, etc.)
- Weekly leaderboard (challenges)
- Category leaderboards (writing, coding, design, etc.)
- Friend leaderboard
- Badges for top performers

---

### 4. GhostClip Viral Loop

#### **Aha! Moment Capture (ReplayKit)**
- One-tap button to save last 30 seconds of session
- Includes: user's typing, Ghost's suggestion, user's reaction, haptic feedback visualization
- Automatically overlay GhostWriter watermark and metadata
- Preview before saving

#### **Clip Editing**
- Trim to exact moment
- Add text overlay
- Choose music/sound effects
- Add personality info
- Add call-to-action (join session, try personality, etc.)

#### **Attribution & Sharing**
- Clips include QR code/Deep Link to:
  - Join this Ghost Session
  - Try this Personality
  - Follow this Creator
- Seamless export to TikTok, Instagram Reels, YouTube Shorts
- Pre-filled captions with process description
- Creator's handle and links in description

#### **Clip Monetization**
- Creators earn CPM from clip views
- Brands can sponsor clips
- Viewers can tip creators
- Clips link to creator's Patreon/Ko-fi
- Revenue splits for collaborations

#### **Viral Mechanics**
- Trending clips on home feed
- Clips with high engagement get promoted
- Personality showcase (see how others use it)
- Challenge submissions (best clip wins)
- Referral bonus (share clip, both get credits)

---

### 5. Onboarding & First Spark (Optimized)

#### **Step 1: Value Prop (15 seconds)**
- "Your AI Creative Partner"
- Show GhostClip of someone having an "aha!" moment
- CTA: "Create Your First Spark"

#### **Step 2: Personality Quiz (30 seconds)**
- "What's your creative style?"
- Questions:
  - Messy brainstormer or precision editor?
  - Fast and loose or thoughtful and deliberate?
  - Prefer encouragement or constructive criticism?
  - Solo or collaborative?
- Assigns personality match

#### **Step 3: First Session (3 minutes)**
- Guided 3-minute session with matched personality
- Ghost AI gives 2-3 suggestions
- User accepts/rejects suggestions
- Haptic feedback on each interaction
- Real-time word count and flow score

#### **Step 4: First Spark (1 minute)**
- User's first idea is captured
- Show it as a "GhostClip" (30-second highlight)
- CTA: "Share Your Spark" (social share)

#### **Step 5: Monetization Moment (1 minute)**
- "You just created something amazing!"
- Show what Pro users can do:
  - Unlimited sessions
  - More personalities
  - Creator analytics
  - Earn money from clips
- CTA: "Try Pro Free for 7 Days"

#### **Step 6: Social Proof (1 minute)**
- Show trending clips from other creators
- "Join 50K creators using GhostWriter"
- CTA: "Explore Community"

**Total onboarding time**: 10 minutes
**Expected conversion to trial**: 60-70%
**Expected trial-to-paid**: 25-30%

---

### 6. Retention & Engagement Features

#### **Creativity Streak**
- Track consecutive days of creative sessions
- Visual indicator (calendar view)
- Streak milestones (7 days, 30 days, 100 days)
- Streak-breaking notifications
- Leaderboard for longest streaks

#### **Weekly Challenges**
- "Write 500 words this week"
- "Collaborate with 2 friends"
- "Try 3 new personalities"
- "Create a viral clip"
- Leaderboard with rewards
- Sponsored challenges (brands pay)

#### **Achievements & Badges**
- "First Spark" (first session)
- "Collaboration Master" (10 Live Jams)
- "Viral Clip" (1000 views)
- "Personality Creator" (publish personality)
- "Streak Champion" (30-day streak)
- "Creator" (earn $100)
- "Influencer" (1000 followers)

#### **Smart Notifications**
- "You're most creative at 10am on Thursdays—ready to create?"
- "Your streak is 7 days! Keep it going."
- "Friend X is live jamming—join them?"
- "Your latest clip got 100 views!"
- "Trending personality this week: The Architect"
- "You've earned $47 this month!"

#### **Weekly Creative Report**
- Every Sunday, users get email/in-app report:
  - Total creative time
  - Most productive hours
  - Favorite personalities
  - Top clips
  - Collaboration stats
  - Comparison to previous week
  - Earnings

---

## Part 3: GhostWriter — Monetization, Creator Economy, Enterprise Expansion, and App Store Submission

**Objective**: Implement a sustainable, creator-centric monetization model with multiple revenue streams, enterprise features, and a robust compliance strategy for a category-defining App Store launch.

---

### 1. Monetization Strategy (StoreKit 2)

#### **Tier 1: Free**
- 1 Live Jam/month
- 1 basic personality (The Muse)
- 5-minute sessions
- Standard export (with watermark)
- Ad-supported (light, non-intrusive)
- No clip monetization
- **Goal**: Get users hooked on core experience
- **Conversion target**: 5-10% to paid

#### **Tier 2: Creator ($9.99/month or $79/year)**
- Unlimited Live Jams
- 5 personalities (The Muse, The Architect, The Critic, The Visionary, The Analyst)
- Unlimited session length
- High-quality export (no watermark)
- Creator dashboard (analytics, earnings)
- Clip monetization (70% revenue share)
- Weekly creative reports
- Personality customization (basic)
- **Goal**: Convert active users to paying creators
- **Conversion target**: 15-20% of free users

#### **Tier 3: Pro ($19.99/month or $149/year)**
- All Creator features
- 20 personalities (including premium personalities)
- Custom personality builder (visual editor)
- Advanced analytics (mood detection, flow state, etc.)
- Priority support
- Ad-free experience
- Early access to new features
- Exclusive badges
- **Goal**: Capture power users and enthusiasts
- **Conversion target**: 5-10% of free users

#### **Tier 4: Studio ($49.99/month or $399/year)**
- All Pro features
- Team workspace (up to 5 people)
- Team personalities (trained on team's style)
- Team analytics and collaboration logs
- Admin controls and permissions
- Team billing
- Dedicated support
- **Goal**: Capture small teams, agencies, studios
- **Conversion target**: 0.5-1% of free users

#### **Tier 5: Enterprise (Custom pricing)**
- Unlimited everything
- Dedicated support
- Custom integrations
- White-label options
- API access
- Advanced security/SSO
- **Goal**: Enterprise accounts (companies, universities, publishers)
- **Conversion target**: 0.1% of free users

---

### 2. Additional Revenue Streams

#### **Personality Marketplace**
- Users publish custom personalities ($1.99-$9.99)
- App takes 30%, creator gets 70%
- Premium personality templates ($2.99 each)
- Exclusive personalities for Pro/Studio tiers
- **Projected revenue**: $500K-$2M annually at scale

#### **Premium Voices**
- Users choose voice for Ghost AI (male, female, celebrity, robotic, etc.)
- Premium voices cost $0.99 each
- App takes 30%, voice provider gets 70%
- **Projected revenue**: $100K-$500K annually

#### **Session Templates**
- Pre-built session structures for common tasks
- Examples: "Blog Post Outline," "Product Pitch," "Song Lyrics," "Code Refactor"
- Premium templates $2.99 each
- **Projected revenue**: $200K-$1M annually

#### **Clip Monetization (CPM-Based)**
- Creators earn from clip views (YouTube-style CPM)
- Average CPM: $2-5 per 1000 views
- App takes 30%, creator gets 70%
- **Projected revenue**: $2M-$10M annually at scale

#### **Sponsored Challenges**
- Brands pay to sponsor weekly challenges ($10K-$50K per week)
- Challenge winners get brand rewards
- Clips tagged with brand
- **Projected revenue**: $2M-$5M annually

#### **API Access**
- Developers pay to build on GhostWriter ($99/mo)
- Access to personality engine, session data, etc.
- **Projected revenue**: $100K-$500K annually

#### **Tipping**
- Viewers can tip creators directly ($1, $5, $10)
- App takes 30%, creator gets 70%
- **Projected revenue**: $500K-$2M annually

#### **Affiliate Revenue**
- Link to creative tools (Notion, Figma, GitHub, etc.)
- Earn commission on referrals
- **Projected revenue**: $100K-$500K annually

---

### 3. Projected Revenue Model

#### **Year 1**
- 100K free users
- 10K Creator tier ($9.99/mo) = $1.2M
- 5K Pro tier ($19.99/mo) = $1.2M
- 500 Studio tier ($49.99/mo) = $300K
- Marketplace/templates/sponsorships = $500K
- **Total Year 1**: ~$3.2M ARR

#### **Year 2**
- 1M free users
- 100K Creator tier = $12M
- 50K Pro tier = $12M
- 5K Studio tier = $3M
- Marketplace/templates/sponsorships/CPM = $8M
- **Total Year 2**: ~$35M ARR

#### **Year 3**
- 5M free users
- 500K Creator tier = $60M
- 200K Pro tier = $48M
- 50K Studio tier = $30M
- Marketplace/templates/sponsorships/CPM = $50M
- **Total Year 3**: ~$188M ARR

#### **Path to $1B+**
- Year 4-5: Expand internationally, add enterprise features, reach $500M+ ARR
- Year 5-6: Reach $1B+ ARR through scale and new revenue streams

---

### 4. App Store Compliance & Trust

#### **Privacy Manifest**
- Explicitly declare all on-device processing
- No data collection of creative sessions by default
- Optional cloud sync for backup (user-controlled)
- Clear privacy policy
- Transparent about what data is stored where

#### **Safety Guardrails**
- Implement on-device content filtering for AI suggestions
- Prevent harmful, illegal, or prohibited content
- Moderation tools for public sessions and clips
- Report and block functionality for users
- COPPA compliance for users under 13

#### **Transparency**
- Clearly state that AI is a "collaborative tool"
- Not a replacement for human creativity
- Disclose that on-device LLMs have limitations
- Show confidence scores for suggestions
- Allow users to opt-out of AI features

#### **Accessibility**
- VoiceOver support
- Dyslexia-friendly fonts
- High contrast mode
- Adjustable text size
- Haptic feedback as alternative to visual cues

---

### 5. Product Page & ASO

#### **App Name**
GhostWriter AI

#### **Subtitle**
Your Live Creative Partner

#### **Keywords**
live brainstorming, shareplay collaboration, creative flow, AI writing partner, dynamic island app, creative assistant, personality ai, live jam, ghostclips, creator app

#### **Description**
GhostWriter is your AI creative partner that transforms solitary thinking into a live, collaborative experience. Write, code, design, or brainstorm with real-time AI suggestions, haptic feedback, and live collaboration via SharePlay. Create viral clips, earn money from your creativity, and join a community of 50K+ creators.

**Features:**
- Live AI suggestions with confidence scoring
- Real-time collaboration (Live Jam via SharePlay)
- Custom AI personalities (build your own)
- Creator marketplace (earn from personalities and clips)
- Viral clip creation and monetization
- Weekly challenges and leaderboards
- Creator analytics and earnings dashboard
- Offline support (works without internet)
- Voice-first mode (dictation support)
- Integrations with Notion, GitHub, Figma, and more

#### **Screenshot Storyboard**
1. **The Pulse**: Dynamic Island showing active session with word count and personality
2. **The Jam**: Two friends on FaceTime collaborating on GhostBoard with shared cursor
3. **The Spark**: AI suggestion appearing with glow effect and confidence score
4. **The Clip**: 30-second GhostClip of "aha!" moment ready to share
5. **The Creator**: Creator profile showing earnings, followers, and top clips
6. **The Marketplace**: Browsing custom personalities from other creators
7. **The Community**: Leaderboard and trending clips from creators worldwide

---

### 6. Submission Readiness

#### **QA Evidence**
- Recorded SharePlay sessions showing low-latency sync
- Multiple session types working correctly
- Haptic feedback demonstrations
- Dynamic Island updates
- Offline functionality

#### **CoreML Validation**
- Proof of on-device model performance on iPhone 13+
- Benchmarks showing <100ms suggestion latency
- Memory usage within limits
- Battery impact analysis

#### **Privacy Documentation**
- Detailed explanation of on-device processing
- No data collection of creative content
- Clear opt-in for cloud sync
- Privacy manifest compliance

#### **Reviewer Demo Guide**
- Step-by-step guide to trigger Ghost suggestions
- How to start a Live Jam (with test account)
- How to create and share a GhostClip
- How to access creator dashboard
- How to try different personalities

#### **Content Policy Compliance**
- Safety guardrails for AI suggestions
- Moderation tools for public content
- COPPA compliance
- No prohibited content

---

### 7. Launch Strategy & Timeline

#### **Phase 0: MVP (Weeks 0-12)**
- Core session engine (typing, Ghost AI suggestions, haptics)
- 4 basic personalities (pre-built)
- Live Jam (SharePlay collaboration)
- GhostClips (30-second capture + export)
- Basic freemium model (Free + Pro)
- Onboarding flow
- Dynamic Island integration

#### **Phase 1: Creator Economy (Months 3-6)**
- Personality marketplace
- Creator dashboard (analytics, earnings)
- Session discovery feed
- Trending personalities/challenges
- Referral program
- Push notifications
- Weekly creative reports

#### **Phase 2: Expansion (Months 6-12)**
- Clip monetization (CPM-based)
- Creator revenue share
- Team/workspace features
- Cross-platform sync (iPad, Mac)
- Creative tool integrations (Notion, GitHub, Figma)
- Voice-first mode
- Session replay & editing

#### **Phase 3: Enterprise & Scale (Months 12+)**
- Enterprise features (white-label, SSO, etc.)
- Advanced analytics
- API access for developers
- International expansion
- Additional personality types
- Sponsored challenges

---

### 8. Key Success Metrics

#### **Acquisition**
- DAU/MAU
- Conversion rate (free → trial)
- Trial-to-paid conversion (target: 25-30%)
- CAC (cost per acquisition)

#### **Engagement**
- Session frequency (sessions/user/week)
- Session duration (minutes)
- Live Jam participation rate
- Clip creation rate
- Personality adoption rate

#### **Retention**
- D1, D7, D30 retention (target: 50%, 40%, 25%)
- Churn rate
- Streak completion rate
- Repeat creator rate

#### **Monetization**
- ARPU (average revenue per user)
- LTV (lifetime value, target: $120-150)
- LTV:CAC ratio (target: >3:1)
- Marketplace revenue
- Creator earnings

#### **Virality**
- Clip shares per user
- Referral rate
- Viral coefficient (target: 0.3-0.5)
- Social media impressions

#### **Creator Economy**
- Creator count
- Average creator earnings
- Top creator earnings
- Creator retention rate
- Personality marketplace revenue

---

### 9. Competitive Advantages

#### **vs. Notion AI**
- Real-time collaboration (Live Jam)
- Haptic feedback (unique sensory experience)
- Viral clip sharing (GhostClips)
- Creator marketplace (monetization)
- Mobile-first (not web-only)

#### **vs. ChatGPT / Claude**
- Live, real-time interaction (not turn-based)
- Haptic feedback (physical connection)
- Collaborative (not solo)
- Mobile-first (not web)
- Personality customization (not generic)
- Creator economy (earn money)

#### **vs. Copilot / GitHub Codespace**
- Broader use cases (not just coding)
- Haptic feedback
- Collaborative (not solo)
- Personality-driven (not just code completion)
- Creator marketplace

#### **vs. Otter.ai (voice)**
- Real-time collaboration
- Haptic feedback
- Creative (not just transcription)
- Personality-driven
- Monetization for creators

#### **vs. BeReal / Vibe**
- Focus on creative process (not presence/status)
- Monetization (creators earn money)
- Collaboration (not solo)
- Personality-driven (not generic)

---

### 10. Deliverable

**A category-defining iOS application that turns the solitary act of creative thinking into a live, collaborative, monetizable, and shareable performance.**

GhostWriter is not just another AI app—it's a new category: **The Creator's AI Partner**. It combines:
- On-device AI (privacy-first)
- Live collaboration (SharePlay)
- Haptic feedback (sensory connection)
- Creator marketplace (monetization)
- Viral growth loops (GhostClips)

**Expected outcome**: $150-250M ARR by Year 3, with a clear path to $1B+ valuation and category leadership.

---

## Summary: Why This Prompt is Optimized

1. **Creator-centric from day one** (not an afterthought)
2. **Multiple revenue streams** (not just subscriptions)
3. **Built-in virality** (GhostClips, referrals, challenges)
4. **Clear retention mechanics** (streaks, challenges, analytics)
5. **Defensible moat** (on-device AI, personality marketplace, community)
6. **Faster path to profitability** (Year 1: $3M, Year 2: $35M, Year 3: $188M)
7. **Lower regulatory risk** (privacy-first, on-device processing)
8. **Accessible to all creators** (writing, coding, design, brainstorming)
9. **Enterprise-ready** (team features, integrations, white-label)
10. **Investment-ready** (clear metrics, proven model, $1B+ path)

This is a complete, investment-ready, category-defining product specification.
