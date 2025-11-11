# Airtable Token Setup Checklist

You're getting 403 errors, which means the token configuration is incomplete. Let's verify each step carefully.

## ✅ Token Configuration Checklist

When you're at https://airtable.com/create/tokens creating your token, verify EACH of these:

### 1. Token Name
- [ ] Named something like "Foundation Grants R Script"

### 2. Scopes (Permissions)
Click "Add a scope" and add EACH of these three:

- [ ] `data.records:read` ← Can read records from tables
- [ ] `data.records:write` ← Can create/update records
- [ ] `schema.bases:read` ← Can read base structure

**IMPORTANT:** All three scopes must be checked/added!

### 3. Access (Most Common Issue!)
This is where you specify WHICH base the token can access:

- [ ] Click "Add a base" button
- [ ] Select "Foundation Grants Data" from the dropdown
- [ ] Verify it appears in the list under "This token can access:"
- [ ] Should show: "Foundation Grants Data" with ID `appjlMJMGVV53ehJx`

**CRITICAL:** If you don't add the base here, you'll get 403 errors even with correct scopes!

### 4. Create and Copy
- [ ] Click "Create token" button
- [ ] Immediately copy the ENTIRE token (it's shown only once!)
- [ ] Token should be ~80-90 characters long
- [ ] Should have format: `patXxxxxx.xxxxxxxx...` (with a dot in middle)

---

## 🔍 How to Verify Your Current Token

Go to https://airtable.com/create/tokens and find your token. You should see:

```
Token Name: Foundation Grants R Script
Scopes: 3 scopes
Access: 1 base
```

If it says "Access: 0 bases", that's the problem!

### To Fix:
1. Click "Edit" on your token
2. Scroll to "Access" section
3. Click "Add a base"
4. Select "Foundation Grants Data"
5. Click "Save changes"
6. **Don't need to regenerate** - the existing token will now work!

---

## 🎯 What To Do Now

**Option A: Fix your existing token (if you can see it)**
1. Go to https://airtable.com/create/tokens
2. Find the token you just created
3. Click "Edit"
4. Check that all 3 scopes are there
5. **Add the base** if it's missing
6. Save
7. Tell me "I fixed it" and I'll test again

**Option B: Start fresh (if confused)**
1. Delete the old token
2. Create new one following checklist above
3. Copy the complete token
4. Reply with the new token

Which option would you like to try?
