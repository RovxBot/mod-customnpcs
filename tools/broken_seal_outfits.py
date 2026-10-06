"""Authoring contract for fully clothed, native campaign humanoid outfits."""
VALID_CLASSES=set(range(1,10)) | {11}
VALID_RACES=set(range(1,9)) | {10,11}


def validate_outfits(actors):
    for actor in actors:
        outfit=actor.get('outfit')
        if not outfit:
            continue
        assert outfit.get('class',1) in VALID_CLASSES, ('Invalid rendering class',actor['key'] if 'key' in actor else actor['entry'])
        assert outfit['race'] in VALID_RACES and outfit.get('gender',0) in [0,1], actor
        assert outfit.get('chest') and outfit.get('legs'), ('Incomplete campaign clothing',actor)
