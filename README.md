# **TaskHub - Flutter Task Management App**  
*A sleek, GitHub-inspired task manager with persistent login, auto-cleanup, and theming.*  

**[Download APK](https://drive.google.com/file/d/1ok_baCWRx1KU-isxHYwClWvENV4MhcDx/view?usp=sharing)** | **[Demo Video](https://drive.google.com/file/d/1VQ0_3CIVls60c32Hqp8ja974sGas6BTp/view?usp=drive_link)** 

---

## **📌 Features**  

### **Persistent Login**  
- Secure authentication using **Supabase Auth**  
- Session persists across app restarts  

### **Supabase Integration**  
- Real-time task sync with **PostgreSQL**  
- **Auto-deletes completed tasks after 24h** via `pg_cron` policy  

### **Dynamic Theming**  
- Light/dark mode support  
- Customizable UI colors  

### **GitHub-Style Layout**  
- Clean, minimalist UI inspired by GitHub  
- Commit-style calendar for tracking task completion  

### **State Management with Provider**  
- Efficient state handling using **Provider (v6.1.4)**  
- Smooth UI updates without unnecessary rebuilds  

--- 

Let me know if you’d like a deeper dive into any of these! 😊

## **🛠️ Tech Stack**  
| **Category**       | **Technology**                     |
|--------------------|-----------------------------------|
| **Backend**        | Supabase (PostgreSQL + Auth)      |
| **State Management** | Provider                         |
| **Localization**   | `intl` (for date formatting)      |
| **UI Framework**   | Flutter (Material 3)              |

---

## **📦 Dependencies**  
```yaml
dependencies:
  supabase_flutter: ^2.8.4  # Supabase integration
  provider: ^6.1.4          # State management
  intl: ^0.20.2             # Date/time formatting
```

---

## **📸 Screenshots**  

| Login Screen | Sign Up Screen | Dashboard (Light) | Dashboard (Dark) |
|------------------------------------------------------------------------|------------------------------------------------------------------|----------------------------------------------------------------------------|----------------------------------------------------------------------------|
| [![Whats-App-Image-2025-04-20-at-2-39-03-AM.jpg](https://i.postimg.cc/2yj5CVsc/Whats-App-Image-2025-04-20-at-2-39-03-AM.jpg)](https://postimg.cc/qhYrLMMy)| [![Whats-App-Image-2025-04-20-at-2-39-03-AM-1.jpg](https://i.postimg.cc/9MYM3Gnw/Whats-App-Image-2025-04-20-at-2-39-03-AM-1.jpg)](https://postimg.cc/jwCKPJKR)| [![Whats-App-Image-2025-04-22-at-11-32-43-PM.jpg](https://i.postimg.cc/tRmcwkS5/Whats-App-Image-2025-04-22-at-11-32-43-PM.jpg)](https://postimg.cc/c6wT8RNg)| [![Whats-App-Image-2025-04-22-at-11-32-43-PM-1.jpg](https://i.postimg.cc/SR5t9Q25/Whats-App-Image-2025-04-22-at-11-32-43-PM-1.jpg)](https://postimg.cc/m1YwfsSN)|

---

## **⚙️ Build Instructions**  

### **1. Clone the Repository**  
```bash
git clone https://github.com/Sh1vT/taskhub.git
cd taskhub
```

### **2. Set Up Supabase**  
- Create a project at [supabase.com](https://supabase.com)  
- Enable **Auth** and **Database**  
- Add your `SUPABASE_URL` as `supabaseUrl` and `SUPABASE_ANON_KEY` as `publicKey` in `lib/utils/validators.dart` 

### **3. Install Dependencies**  
```bash
flutter pub get
```

### **4. Run the App**  
```bash
flutter run
```

### **5. Build for Release**  
```bash
flutter build apk --release  # Android
flutter build ios            # iOS (requires Xcode)
```

---

## **🔧 Supabase Auto-Cleanup Policy**  
Tasks marked as `completed` are **automatically deleted after 24 hours** using:  

```sql
-- PostgreSQL function
CREATE OR REPLACE FUNCTION delete_old_completed_tasks()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  DELETE FROM tasks
  WHERE is_completed = true
  AND created_at < (NOW() - INTERVAL '24 hours');
END;
$$;

-- Schedule daily cleanup
SELECT cron.schedule(
  'delete_completed_tasks_daily',
  '0 3 * * *',  -- Runs at 3 AM daily
  $$SELECT delete_old_completed_tasks()$$
);
```

*(Requires `pg_cron` extension enabled in Supabase)*    

---
## Assignment Specific Question

### **Hot Reload (Like Editing a Draft)**  
Imagine you're writing a story (your app) and want to tweak a sentence. With **Hot Reload**, you make the edit, and the story *magically updates* while keeping your current page open. Your app’s state (like form inputs, navigation, or animations) stays intact—it’s like the app barely notices the change.  

**For example:**  
- "This button should be blue, not red."  
- "I need to adjust this font size real quick."  

---

### **Hot Restart (Like Starting a New Draft)**  
Now imagine you realize your story’s *entire plot* needs reworking. **Hot Restart** closes the book and starts fresh from page one. It wipes all temporary states (like logged-in users or unsaved data) and rebuilds everything from scratch.  

**For Example:** 
- I just added Supabase, need the app to recognize it.
- Why is my navigation stack stuck? Let’s reset everything.

---

### **Project's Example**  
- **Hot Reload:** Editing a task’s UI (e.g., making the "TaskTile" container prettier) *without* losing the current implementation.  
- **Hot Restart:** Modifying `Supabase.initialize()`—because the app needs to *reload your auth setup* entirely.  

This project was made for the TechStax Flutter Developer Assignment. Happy Tasking!
