-- Dummy Rooms Seed

INSERT INTO public.rooms (name, capacity, metadata) VALUES
('Conference Room Alpha', 12, '{"has_projector": true, "has_whiteboard": true}'),
('Meeting Room Beta', 4, '{"has_projector": false, "has_whiteboard": true}'),
('Boardroom Gamma', 20, '{"has_projector": true, "has_whiteboard": true, "video_conferencing": true}'),
('Focus Room 1', 2, '{"has_projector": false, "has_whiteboard": false}');
