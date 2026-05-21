-- ============================================================
-- Fleet Management Setup — Nationwide Semi Trailer Hire
-- Run this in the Supabase Dashboard SQL Editor
-- ============================================================

-- 1. Create the fleet table
CREATE TABLE IF NOT EXISTS fleet (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  image_url TEXT DEFAULT '',
  display_order INT DEFAULT 0,
  active BOOLEAN DEFAULT true
);

-- 2. Enable Row Level Security
ALTER TABLE fleet ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies
-- Public can read active fleet items (for fleet.html and index.html)
CREATE POLICY "Public can read active fleet"
  ON fleet FOR SELECT
  USING (active = true);

-- Authenticated users (admin) can do everything
CREATE POLICY "Admin full access to fleet"
  ON fleet FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 4. Create Storage bucket for fleet images
INSERT INTO storage.buckets (id, name, public)
VALUES ('fleet-images', 'fleet-images', true)
ON CONFLICT (id) DO NOTHING;

-- 5. Storage RLS Policies
-- Anyone can view fleet images (public bucket)
CREATE POLICY "Public can view fleet images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'fleet-images');

-- Authenticated users can upload fleet images
CREATE POLICY "Admin can upload fleet images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'fleet-images' AND auth.role() = 'authenticated');

-- Authenticated users can update fleet images
CREATE POLICY "Admin can update fleet images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'fleet-images' AND auth.role() = 'authenticated');

-- Authenticated users can delete fleet images
CREATE POLICY "Admin can delete fleet images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'fleet-images' AND auth.role() = 'authenticated');

-- 6. Seed data — existing fleet items (using local image paths as starting point)
INSERT INTO fleet (name, description, image_url, display_order, active) VALUES
  ('Flat Top Trailers',       'General freight, steel & machinery',        'images/flat-top.jpg',    1, true),
  ('Tautliner Trailers',      'Palletised goods & distribution',           'images/tautliner.jpg',   2, true),
  ('Drop Deck Trailers',      'Oversized & tall industrial loads',         'images/drop-deck.jpg',   3, true),
  ('Low Loader Trailers',     'Mining equipment & earthmoving',            'images/low-loader.jpg',  4, true),
  ('Extendable Trailers',     'Long loads — steel, timber & piping',       'images/extendable.jpg',  5, true),
  ('Skeletal (Skel) Trailers','20ft & 40ft container transport',           'images/skeleton.jpg',    6, true),
  ('Dolly',                   'B-double & road train configurations',      'images/dolly.jpg',       7, true),
  ('Refrigerated Trailers',   'Cold chain & temperature-controlled',       'images/refrigerated.jpg', 8, true);
