-- Migration 042: Test accounts (one per role)
--
-- Accounts created:
--   owner@gosystem.test    / Owner@Test123    → role: owner
--   manager@gosystem.test  / Manager@Test123  → role: manager
--   admin@gosystem.test    / Admin@Test123    → role: admin
--   cashier@gosystem.test  / Cashier@Test123  → role: cashier
--
-- Run this in the Supabase SQL Editor (not as a push migration,
-- because auth.users is managed by Supabase Auth).

DO $$
DECLARE
  v_owner_id   UUID := 'a1a1a1a1-0001-0001-0001-a1a1a1a1a1a1';
  v_manager_id UUID := 'b2b2b2b2-0002-0002-0002-b2b2b2b2b2b2';
  v_admin_id   UUID := 'c3c3c3c3-0003-0003-0003-c3c3c3c3c3c3';
  v_cashier_id UUID := 'd4d4d4d4-0004-0004-0004-d4d4d4d4d4d4';
BEGIN

  -- ── 1. Create auth.users entries ─────────────────────────────────────────
  INSERT INTO auth.users (
    instance_id, id, aud, role, email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at, updated_at,
    confirmation_token, email_change,
    email_change_token_new, recovery_token
  ) VALUES
    (
      '00000000-0000-0000-0000-000000000000',
      v_owner_id, 'authenticated', 'authenticated',
      'owner@gosystem.test',
      crypt('Owner@Test123', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}', '{}',
      now(), now(), '', '', '', ''
    ),
    (
      '00000000-0000-0000-0000-000000000000',
      v_manager_id, 'authenticated', 'authenticated',
      'manager@gosystem.test',
      crypt('Manager@Test123', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}', '{}',
      now(), now(), '', '', '', ''
    ),
    (
      '00000000-0000-0000-0000-000000000000',
      v_admin_id, 'authenticated', 'authenticated',
      'admin@gosystem.test',
      crypt('Admin@Test123', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}', '{}',
      now(), now(), '', '', '', ''
    ),
    (
      '00000000-0000-0000-0000-000000000000',
      v_cashier_id, 'authenticated', 'authenticated',
      'cashier@gosystem.test',
      crypt('Cashier@Test123', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}', '{}',
      now(), now(), '', '', '', ''
    )
  ON CONFLICT (id) DO NOTHING;

  -- ── 2. Create identity rows (required for email/password login) ──────────
  INSERT INTO auth.identities (
    id, user_id, identity_data, provider,
    last_sign_in_at, created_at, updated_at
  ) VALUES
    (
      v_owner_id, v_owner_id,
      jsonb_build_object('sub', v_owner_id::text, 'email', 'owner@gosystem.test'),
      'email', now(), now(), now()
    ),
    (
      v_manager_id, v_manager_id,
      jsonb_build_object('sub', v_manager_id::text, 'email', 'manager@gosystem.test'),
      'email', now(), now(), now()
    ),
    (
      v_admin_id, v_admin_id,
      jsonb_build_object('sub', v_admin_id::text, 'email', 'admin@gosystem.test'),
      'email', now(), now(), now()
    ),
    (
      v_cashier_id, v_cashier_id,
      jsonb_build_object('sub', v_cashier_id::text, 'email', 'cashier@gosystem.test'),
      'email', now(), now(), now()
    )
  ON CONFLICT (id) DO NOTHING;

  -- ── 3. Create user_profiles entries ──────────────────────────────────────
  INSERT INTO user_profiles (id, full_name, role)
  VALUES
    (v_owner_id,   'مالك التطبيق',  'owner'),
    (v_manager_id, 'مدير النظام',   'manager'),
    (v_admin_id,   'مسؤول الإدارة', 'admin'),
    (v_cashier_id, 'كاشير تجريبي',  'cashier')
  ON CONFLICT (id) DO UPDATE
    SET full_name = EXCLUDED.full_name,
        role      = EXCLUDED.role;

END $$;
